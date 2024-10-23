"
I am a single change chunk in a unified diff.
"
Class {
	#name : #UnifiedDiffChangeChunk,
	#superclass : #Object,
	#instVars : [
		'oldStart',
		'oldCount',
		'newStart',
		'newCount',
		'diffLines'
	],
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #accessing }
UnifiedDiffChangeChunk >> children [
	^ #()
]

{ #category : #accessing }
UnifiedDiffChangeChunk >> description [
	^ self range
]

{ #category : #accessing }
UnifiedDiffChangeChunk >> diffLinesWithPositions [
	| oldPosition newPosition |
	oldPosition := oldStart.
	newPosition := newStart.
	^ diffLines collect: [ :line | | elements |
		elements := { 
			line first = $+ ifTrue: [ nil ] ifFalse: [ oldPosition ] . 
			line first = $- ifTrue: [ nil ] ifFalse: [ newPosition ] . 
			line }.
		line first = $+
			ifFalse: [ oldPosition := oldPosition + 1 ].
		line first = $-
			ifFalse: [ newPosition := newPosition + 1 ].
		elements ]
]

{ #category : #initialization }
UnifiedDiffChangeChunk >> initialize [
	super initialize.
	oldCount := newCount := 1
]

{ #category : #accessing }
UnifiedDiffChangeChunk >> newContents [
	^ String streamContents: [ :out | 
		self newContentsLines do: [ :line | 
			out
				next: line size - 1
				putAll: line
				startingAt: 2.
			out cr ] ]
]

{ #category : #accessing }
UnifiedDiffChangeChunk >> newContentsLineAt: lineNumber [
	^ self newContentsLineAt: lineNumber ifAbsent: [ nil ]
]

{ #category : #accessing }
UnifiedDiffChangeChunk >> newContentsLineAt: lineNumber ifAbsent: absentBlock [
	| newPosition |
	(lineNumber between: newStart and: newStart + newCount - 1)
		ifFalse: [ ^ absentBlock value ].
	newPosition := newStart.
	diffLines do: [ :line |
		(line first = $+ and: [ newPosition = lineNumber ])
			ifTrue: [ ^ line allButFirst ].
		line first = $-
			ifFalse: [ newPosition := newPosition + 1 ] ].
	^ absentBlock value
]

{ #category : #accessing }
UnifiedDiffChangeChunk >> newContentsLines [
	^ diffLines reject: [ : line | line first = $- ]
]

{ #category : #accessing }
UnifiedDiffChangeChunk >> numberOfLinesAdded [
	^ diffLines count: [ :each | each first = $+ ]
]

{ #category : #accessing }
UnifiedDiffChangeChunk >> numberOfLinesChanged [
	^ self numberOfLinesAdded - self numberOfLinesRemoved
]

{ #category : #accessing }
UnifiedDiffChangeChunk >> numberOfLinesModified [
	| removed modified |
	removed := modified := 0.
	diffLines do: [ :each |
		each first = $-
			ifTrue: [ removed := removed + 1 ].
		(each first = $+ and: [ removed > 0 ])
			ifTrue: [ modified := modified + 1. removed := removed - 1 ].
		each first = Character space
			ifTrue: [ removed := 0 ] ].
	^ modified
]

{ #category : #accessing }
UnifiedDiffChangeChunk >> numberOfLinesRemoved [
	^ diffLines count: [ :each | each first = $- ]
]

{ #category : #accessing }
UnifiedDiffChangeChunk >> oldContents [
	^ String streamContents: [ :out | 
		self oldContentsLines do: [ :line | 
			out
				next: line size - 1
				putAll: line
				startingAt: 2.
			out cr ] ]
]

{ #category : #accessing }
UnifiedDiffChangeChunk >> oldContentsLineAt: lineNumber [
	^ self oldContentsLineAt: lineNumber ifAbsent: [ nil ]
]

{ #category : #accessing }
UnifiedDiffChangeChunk >> oldContentsLineAt: lineNumber ifAbsent: absentBlock [
	| oldPosition |
	(lineNumber between: oldStart and: oldStart + oldCount - 1)
		ifFalse: [ ^ absentBlock value ].
	oldPosition := oldStart.
	diffLines do: [ :line |
		(line first = $- and: [ oldPosition = lineNumber ])
			ifTrue: [ ^ line allButFirst ].
		line first = $+
			ifFalse: [ oldPosition := oldPosition + 1 ] ].
	^ absentBlock value
]

{ #category : #accessing }
UnifiedDiffChangeChunk >> oldContentsLines [
	^ diffLines reject: [ : line | line first = $+ ]
]

{ #category : #printing }
UnifiedDiffChangeChunk >> printOn: stream [
	super printOn: stream.
	stream nextPut: $(; nextPutAll: self range; nextPut: $)
]

{ #category : #accessing }
UnifiedDiffChangeChunk >> range [
	oldStart isNil | newStart isNil
		ifTrue: [ ^ '@@ uninitialized @@' ].
	^ '@@ -{1},{2} +{3},{4} @@' format: { 
		oldStart . oldCount . newStart . newCount }
]

{ #category : #parsing }
UnifiedDiffChangeChunk >> readDiffLinesFrom: characterStream [
	| lineReader |
	lineReader := ZnFastLineReader on: characterStream.
	"skip the range line"
	lineReader nextLine.
	diffLines := Array streamContents: [ :out |
		[ characterStream atEnd or: [ (' +-\' includes: characterStream peek) not ] ] whileFalse: [ 
			lineReader nextLine ifNotNil: [ :line | 
				line first = $\ ifFalse: [ out nextPut: line ] ] ] ]
]

{ #category : #parsing }
UnifiedDiffChangeChunk >> readDiffLinesFromLines: lineStream [
	diffLines := Array streamContents: [ :out |
		[ lineStream atEnd 
			or: [ lineStream peek isEmptyOrNil not
					and: [ (' +-\' includes: lineStream peek first) not ] ] ] 
			whileFalse: [ 
				lineStream next ifNotNil: [ :line | 
					line first = $\ ifFalse: [ out nextPut: line ] ] ] ]
]

{ #category : #parsing }
UnifiedDiffChangeChunk >> readFrom: characterStream [
	self readRangeFrom: characterStream.
	self readDiffLinesFrom: characterStream
]

{ #category : #parsing }
UnifiedDiffChangeChunk >> readFromLines: lineStream [
	self readRangeFrom: lineStream next readStream.
	self readDiffLinesFromLines: lineStream
]

{ #category : #parsing }
UnifiedDiffChangeChunk >> readRangeFrom: characterStream [
	"@@ -s,l +s,l @@ optional section heading"

	| parentCount |
	parentCount := -1.
	[ characterStream peekFor: $@ ]
		whileTrue: [ parentCount := parentCount + 1 ].
	self assert: parentCount = 1.
	characterStream skipSeparators.
	self assert: (characterStream peekFor: $-).
	oldStart := Integer readFrom: characterStream.
	(characterStream peekFor: $,)
		ifTrue: [ oldCount := Integer readFrom: characterStream ].
	characterStream skipSeparators.
	self assert: (characterStream peekFor: $+).
	newStart := Integer readFrom: characterStream.
	(characterStream peekFor: $,)
		ifTrue: [ newCount := Integer readFrom: characterStream ].
]
