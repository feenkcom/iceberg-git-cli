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

{ #category : #initialization }
UnifiedDiffChangeChunk >> initialize [
	super initialize.
	oldCount := newCount := 1
]

{ #category : #accessing }
UnifiedDiffChangeChunk >> newContents [
	^ String streamContents: [ :out |
		diffLines do: [ :line |
			line first = $-
				ifFalse: [ 
					out 
						next: line size - 1 
						putAll: line 
						startingAt: 2.
					out cr ] ] ]
]

{ #category : #accessing }
UnifiedDiffChangeChunk >> oldContents [
	^ String streamContents: [ :out |
		diffLines do: [ :line |
			line first = $+
				ifFalse: [ 
					out 
						next: line size - 1 
						putAll: line 
						startingAt: 2.
					out cr ] ] ]
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
		[ stream atEnd or: [ stream peek = $@ ] ] whileFalse: [ 
			lineReader nextLine ifNotNil: [ :line | out nextPut: line ] ] ]
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
