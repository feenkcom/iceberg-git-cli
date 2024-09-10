"
A git file status for a path

Any of #typeChange #deleted #renamed #copied #updatedUnmerged #modified #unknown #added #unmodified #ignored

For #renamed and #copied there is an original path as well
"
Class {
	#name : #PureGitFileStatus,
	#superclass : #PureGitRepositoryObject,
	#instVars : [
		'path',
		'statusInIndex',
		'originalPath',
		'statusInWorkTree'
	],
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #accessing }
PureGitFileStatus >> fileReference [
	^ self repository location / self path
]

{ #category : #private }
PureGitFileStatus >> fileStatusTable [
	^ {
		$ -> #unmodified.
		
		$? -> #unknown.
		$! -> #ignored.

		$A -> #added.
		$M -> #modified.
		$T -> #typeChange.
		$D -> #deleted.
		$R -> #renamed.
		$C -> #copied.
		$U -> #updatedUnmerged
	} asDictionary
]

{ #category : #'initialization ' }
PureGitFileStatus >> fromLine: line [
	| statusChar |
	statusChar := line trimLeft first.
	statusInIndex := self fileStatusTable at: line first.
	statusInWorkTree := self fileStatusTable at: line second.
	(#(renamed copied) includes: statusInIndex)
		ifTrue: [ | parts |
			parts := ' -> ' split: (line copyFrom: 4 to: line size).
			originalPath := parts first.
			path := parts second ]
		ifFalse: [
			path := line copyFrom: 4 to: line size ]
]

{ #category : #'as yet unclassified' }
PureGitFileStatus >> gtDetails [
	^ super gtDetails , {
		{ 'path' . self path . self fileReference }.
		{ 'original path' . self originalPath ifNil: [ '' ] . self originalPath }.
		{ 'status in index' . self statusInIndex }.
		{ 'status in work tree' . self statusInWorkTree }
	}
]

{ #category : #accessing }
PureGitFileStatus >> originalPath [
	^ originalPath
]

{ #category : #accessing }
PureGitFileStatus >> originalPath: aPathString [
	originalPath := aPathString
]

{ #category : #accessing }
PureGitFileStatus >> path [
	^ path
]

{ #category : #accessing }
PureGitFileStatus >> path: aPathString [
	path := aPathString
]

{ #category : #printing }
PureGitFileStatus >> printOn: stream [
	super printOn: stream.
	stream nextPut: $(.
	stream nextPutAll: statusInIndex.
	stream nextPut: $/.
	stream nextPutAll: statusInWorkTree
	stream space.
	stream nextPutAll: path.
	stream nextPut: $)
]

{ #category : #accessing }
PureGitFileStatus >> statusInIndex [
	^ statusInIndex
]

{ #category : #accessing }
PureGitFileStatus >> statusInIndex: aStatusSymbol [
	statusInIndex := aStatusSymbol
]

{ #category : #accessing }
PureGitFileStatus >> statusInWorkTree [
	^ statusInWorkTree
]

{ #category : #accessing }
PureGitFileStatus >> statusInWorkTree: aStatusSymbol [
	statusInWorkTree := aStatusSymbol
]