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

{ #category : #operations }
UnifiedDiff >> applyTo: input [
	| lines lineNumber |
	lines := input lines.
	lineNumber := 1.
	^ String streamContents: [ :out |
		self changeChunks do: [ :changeChunk | 
			[ lineNumber < changeChunk effectiveOldStart ]
				whileTrue: [
					out nextPutAll: (lines at: lineNumber); cr.
					lineNumber := lineNumber + 1 ].
			changeChunk newContentsLines do: [ :line |
				out next: line size - 1 putAll: line startingAt: 2; cr ].
			lineNumber := lineNumber + changeChunk oldCount ].
		[ lineNumber <= lines size ]
			whileTrue: [
				out nextPutAll: (lines at: lineNumber); cr.
				lineNumber := lineNumber + 1 ] ]
]

{ #category : #operations }
UnifiedDiff >> applyToLines: lines [
	| oldLineNumber newLineNumber |
	oldLineNumber := newLineNumber := 1.
	^ Array streamContents: [ :out |
		self changeChunks do: [ :changeChunk | 
			[ oldLineNumber < changeChunk effectiveOldStart ]
				whileTrue: [
					out nextPut: (lines at: oldLineNumber).
					oldLineNumber := oldLineNumber + 1.
					newLineNumber := newLineNumber + 1 ].
			changeChunk newContentsLines do: [ :line |
				out nextPut: line allButFirst ].
			oldLineNumber := oldLineNumber + changeChunk oldCount.
			newLineNumber := newLineNumber + changeChunk newCount ].
		[ oldLineNumber <= lines size ]
			whileTrue: [
				out nextPut: (lines at: oldLineNumber).
				oldLineNumber := oldLineNumber + 1.
				newLineNumber := newLineNumber + 1 ] ]
]

{ #category : #accessing }
UnifiedDiff >> changeChunks [
	^ changeChunks
]

{ #category : #accessing }
UnifiedDiff >> children [
	^ self changeChunks
]

{ #category : #accessing }
UnifiedDiff >> description [
	^ String streamContents: [ :out |
		self isNewFile ifTrue: [ out nextPutAll: 'new:' ].
		self isDeletedFile ifTrue: [ out nextPutAll: 'deleted:' ].
		self isRename ifTrue: [ out nextPutAll: 'renamed:' ].
		self isModification ifTrue: [ out nextPutAll: 'modified:' ].
		out space; nextPutAll: self header.
		out space; nextPut: $+; print: self numberOfLinesAdded; space; nextPut: $-; print: self numberOfLinesRemoved ]
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
UnifiedDiff >> isModification [
	^ (self isNewFile | self isDeletedFile | self isRename) not
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
	^ self changeChunks sum: [ :each | each numberOfLinesAdded ]
]

{ #category : #accessing }
UnifiedDiff >> numberOfLinesChanged [
	^ self changeChunks sum: [ :each | each numberOfLinesChanged ]
]

{ #category : #accessing }
UnifiedDiff >> numberOfLinesModified [
	^ self changeChunks sum: [ :each | each numberOfLinesModified ]
]

{ #category : #accessing }
UnifiedDiff >> numberOfLinesRemoved [
	^ self changeChunks sum: [ :each | each numberOfLinesRemoved ]
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
UnifiedDiff >> readFrom: characterStream [
	| lineReader savedPosition peekedLine |
	lineReader := ZnFastLineReader on: characterStream.
	self readHeaderFrom: lineReader nextLine.
	[ savedPosition := characterStream position.
	peekedLine := lineReader nextLine.
	characterStream position: savedPosition.
	(characterStream atEnd 
		or: [ (peekedLine beginsWith: '@@') 
			or: [ peekedLine beginsWith: 'diff' ] ]) ]
		whileFalse: [ self readHeaderFrom: lineReader nextLine ].
	changeChunks := Array streamContents: [ :out |
		[ lineReader atEnd or: [ (characterStream peek = $@) not ] ]
			whileFalse: [ out nextPut: (UnifiedDiffChangeChunk new readFrom: characterStream) ] ]
]

{ #category : #parsing }
UnifiedDiff >> readFromLines: lineStream [
	self readHeaderFrom: lineStream next.
	[ lineStream atEnd
		or: [ (lineStream peek beginsWith: '@@')
			or: [ lineStream peek beginsWith: 'diff' ] ] ]
		whileFalse: [ self readHeaderFrom: lineStream next ].
	changeChunks := Array streamContents: [ :out | 
		[ lineStream atEnd or: [ (lineStream peek beginsWith: '@@') not ] ]
			whileFalse: [ out nextPut: (UnifiedDiffChangeChunk new readFromLines: lineStream) ] ]
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
