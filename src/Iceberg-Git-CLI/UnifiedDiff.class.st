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
		'changeChunks',
		'newFile',
		'deletedFile'
	],
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #accessing }
UnifiedDiff >> changeChunks [
	^ changeChunks
]

{ #category : #accessing }
UnifiedDiff >> header [
	^ self isRename 
		ifTrue: [ oldPath , ' > ' , newPath ]
		ifFalse: [ oldPath ifNil: [ '' ] ]
]

{ #category : #'initialization ' }
UnifiedDiff >> initialize [
	super initialize.
	newFile := deletedFile := false
]

{ #category : #testing }
UnifiedDiff >> isDeletedFile [
	^ deletedFile
]

{ #category : #testing }
UnifiedDiff >> isNewFile [
	^ newFile
]

{ #category : #testing }
UnifiedDiff >> isRename [
	^ oldPath ~= newPath
]

{ #category : #accessing }
UnifiedDiff >> newPath [
	^ newPath
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
UnifiedDiff >> numberOfLinesChanged [
	^ self changeChunks sum: [ : each | each numberOfLinesChanged ]
]

{ #category : #accessing }
UnifiedDiff >> numberOfLinesModified [
	^ self changeChunks sum: [ : each | each numberOfLinesModified ]
]

{ #category : #accessing }
UnifiedDiff >> numberOfLinesRemoved [
	^ self changeChunks sum: [ : each | each numberOfLinesRemoved ]
]

{ #category : #accessing }
UnifiedDiff >> oldPath [
	^ oldPath
]

{ #category : #accessing }
UnifiedDiff >> paths [
	^ self isRename 
		ifTrue: [ Array with: oldPath with: newPath ]
		ifFalse: [ Array with: oldPath ]
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
	| lineReader savedPosition peekedLine |
	lineReader := ZnFastLineReader on: stream.
	self readHeaderFrom: lineReader nextLine.
	[ savedPosition := stream position.
	peekedLine := lineReader nextLine.
	stream position: savedPosition.
	(peekedLine beginsWith: '@@') or: [ peekedLine beginsWith: 'diff' ] ]
		whileFalse: [ self readHeaderFrom: lineReader nextLine ].
	changeChunks := Array streamContents: [ :out |
		[ lineReader atEnd or: [ (stream peek = $@) not ] ]
			whileFalse: [ out nextPut: (UnifiedDiffChangeChunk new readFrom: stream) ] ]
]

{ #category : #parsing }
UnifiedDiff >> readHeaderFrom: aLine [
	| elements |
	elements := aLine splitOn: [ :each | each isSeparator ].
	elements first = 'diff'
		ifTrue: [ oldPath := elements third.
			^ newPath := elements fourth ].
	elements first = '---' ifTrue: [ ^ elements second = '/dev/null' ifFalse: [ oldPath := elements second ] ].
	elements first = '+++' ifTrue: [ ^ elements second = '/dev/null' ifFalse: [ newPath := elements second ] ].
	elements first = 'new' ifTrue: [ ^ newFile := true ].
	elements first = 'deleted' ifTrue: [ ^ deletedFile := true ]
]
