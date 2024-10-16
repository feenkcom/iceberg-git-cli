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
UnifiedDiffChangeChunk >> readFrom: stream [
	self readRangeFrom: stream.
	self readLinesFrom: stream
]

{ #category : #parsing }
UnifiedDiffChangeChunk >> readLinesFrom: stream [
	| lineReader |
	lineReader := ZnFastLineReader on: stream.
	"skip the range line"
	lineReader nextLine.
	diffLines := Array streamContents: [ :out |
		[ stream atEnd or: [ (' +-\' includes: stream peek) not ] ] whileFalse: [ 
			lineReader nextLine ifNotNil: [ :line | 
				line first = $\ ifFalse: [ out nextPut: line ] ] ] ]
]

{ #category : #parsing }
UnifiedDiffChangeChunk >> readRangeFrom: stream [
	"@@ -s,l +s,l @@ optional section heading"

	| parentCount |
	parentCount := -1.
	[ stream peekFor: $@ ]
		whileTrue: [ parentCount := parentCount + 1 ].
	self assert: parentCount = 1.
	stream skipSeparators.
	self assert: (stream peekFor: $-).
	oldStart := Integer readFrom: stream.
	(stream peekFor: $,)
		ifTrue: [ oldCount := Integer readFrom: stream ].
	stream skipSeparators.
	self assert: (stream peekFor: $+).
	newStart := Integer readFrom: stream.
	(stream peekFor: $,)
		ifTrue: [ newCount := Integer readFrom: stream ].
]
