"
A git file status for a path.

Any of #typeChange #deleted #renamed #copied #updatedUnmerged #modified #unknown #added #unmodified #ignored

For #renamed and #copied there is an original path as well.

I hold both a status of my path in the index or staging area as well as in the work tree.
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
	#category : #'Iceberg-Git-CLI-Pure-Core'
}

{ #category : #'initialization ' }
PureGitFileStatus >> beUnmodified [
	statusInIndex := statusInWorkTree := #unmodified
]

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
		$T -> #typeChanged.
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

{ #category : #accessing }
PureGitFileStatus >> gitFile [
	^ self repository resolveFilePath: self path
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
	stream nextPutAll: self statusSummary.
	stream space.
	stream nextPutAll: path.
	stream nextPut: $)
]

{ #category : #accessing }
PureGitFileStatus >> stagedChanges [
	^ self repository diffTool
		diffArgs: { '--staged' . self path };
		diff
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

{ #category : #accessing }
PureGitFileStatus >> statusSummary [
	^ String streamContents: [ :out |
		out nextPutAll: statusInIndex.
		out nextPut: $/.
		out nextPutAll: statusInWorkTree ]
]

{ #category : #accessing }
PureGitFileStatus >> unstagedChanges [
	^ self repository diffTool
		diffArgs: { self path };
		diff
]
