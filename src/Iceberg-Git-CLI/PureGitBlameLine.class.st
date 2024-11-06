"
I match a text line at a line number with the commit that last changed it.
I am the result of git blame. 
"
Class {
	#name : #PureGitBlameLine,
	#superclass : #Object,
	#instVars : [
		'line',
		'lineNumber',
		'commit',
		'path'
	],
	#category : #'Iceberg-Git-CLI-Pure-Analysis'
}

{ #category : #accessing }
PureGitBlameLine >> author [
	^ commit author
]

{ #category : #accessing }
PureGitBlameLine >> commit [
	^ commit
]

{ #category : #accessing }
PureGitBlameLine >> commit: aHash [
	commit := aHash
]

{ #category : #accessing }
PureGitBlameLine >> history [
	| spec commits |
	spec := '-L{1},{1}:{2}' format: { self lineNumber . self path }.
	commits := self commit repository 
		queries log: { spec . '--no-patch' }.
	^ commits
		collect: [ :eachCommit | 
			| diffs lines |
			diffs := eachCommit changesToParent diffs
					detect: [ :eachDiff | eachDiff oldPath = self path ].
			lines := diffs changeChunks
					collect: [ :changeChunk | changeChunk newContentsLineAt: self lineNumber ].
			(lines
				select: #notNil
				thenCollect: [ :aLine | 
					PureGitBlameLine new
						commit: eachCommit;
						line: aLine;
						lineNumber: self lineNumber;
						path: self path;
						yourself ]) first ]
]

{ #category : #accessing }
PureGitBlameLine >> line [
	^ line
]

{ #category : #accessing }
PureGitBlameLine >> line: aString [
	line := aString
]

{ #category : #accessing }
PureGitBlameLine >> lineNumber [
	^ lineNumber
]

{ #category : #accessing }
PureGitBlameLine >> lineNumber: anInteger [
	lineNumber := anInteger
]

{ #category : #accessing }
PureGitBlameLine >> path [
	^ path
]

{ #category : #accessing }
PureGitBlameLine >> path: aPathString [
	path := aPathString
]

{ #category : #printing }
PureGitBlameLine >> printOn: stream [
	super printOn: stream.
	stream nextPut: $(.
	stream nextPutAll: path.
	stream nextPut: $:.
	stream print: lineNumber.
	stream nextPut: $)
]

{ #category : #operations }
PureGitBlameLine >> resolveCommitIn: repository using: cache [
	commit := cache 
		at: commit 
		ifAbsentPut: [ repository resolveCommit: commit ]
]

{ #category : #accessing }
PureGitBlameLine >> shortId [
	^ commit shortCommitId
]

{ #category : #accessing }
PureGitBlameLine >> timestamp [
	^ commit timestamp
]
