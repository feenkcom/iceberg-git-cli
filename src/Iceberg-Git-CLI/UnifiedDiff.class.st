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

{ #category : #printing }
UnifiedDiff >> printOn: stream [
	super printOn: stream.
	stream nextPut: $(.
	stream print: oldPath.
	stream nextPut: $,.
	stream print: newPath.
	stream nextPut: $)
]

{ #category : #parsing }
UnifiedDiff >> readFrom: stream [
	| lineReader |
	lineReader := ZnFastLineReader on: stream.
	self readHeaderFrom: lineReader nextLine.
	[ stream peek = $@ ]
		whileFalse: [ lineReader nextLine ].
	changeChunks := Array streamContents: [ :out |
		[ lineReader atEnd ]
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
