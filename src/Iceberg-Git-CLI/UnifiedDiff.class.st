"
I am a unified diff for a single file.
I know my old and new path.
I consist of a number of UnifiedDiffChangeChunks.
"
Class {
	#name : #UnifiedDiff,
	#superclass : #Object,
	#instVars : [
		'oldPath',
		'newPath',
		'changeChunks'
	],
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #accessing }
UnifiedDiff >> changeChunks [
	^ changeChunks
]

{ #category : #accessing }
UnifiedDiff >> header [
	^ oldPath = newPath 
		ifTrue: [ oldPath ]
		ifFalse: [ oldPath , ' > ' , newPath ]
]

{ #category : #accessing }
UnifiedDiff >> numberOfChanges [
	^ self changeChunks size
]

{ #category : #accessing }
UnifiedDiff >> numberOfLinesAdded [
	^ self changeChunks sum: [ : each | each numberOfLinesAdded ]
]

{ #category : #accessing }
UnifiedDiff >> numberOfLinesRemoved [
	^ self changeChunks sum: [ : each | each numberOfLinesRemoved ]
]

{ #category : #printing }
UnifiedDiff >> printOn: stream [
	super printOn: stream.
	stream nextPut: $(.
	stream nextPutAll: self header.
	stream nextPut: $)
]

{ #category : #parsing }
UnifiedDiff >> readFrom: stream [
	| lineReader |
	lineReader := ZnFastLineReader on: stream.
	self readHeaderFrom: lineReader nextLine.
	[ 'd@' includes: stream peek ]
		whileFalse: [ lineReader nextLine ].
	changeChunks := Array streamContents: [ :out |
		[ lineReader atEnd or: [ (stream peek = $@) not ] ]
			whileFalse: [ out nextPut: (UnifiedDiffChangeChunk new readFrom: stream) ] ]
]

{ #category : #parsing }
UnifiedDiff >> readHeaderFrom: aLine [
	| elements |
	elements := Character space split: aLine.
	self assert: elements first = 'diff'.
	oldPath := elements third.
	newPath := elements fourth
]
