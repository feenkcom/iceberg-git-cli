"
I am an actual git commit.

A commit is a tree with meta data. 

The meta data consists of the timestamp, author, parent ids and comment.

A commit's hash (id) identifies it in the git object database.

My tree describes the whole state of the repository at the moment the commit was created.
"
Class {
	#name : #PureGitCommit,
	#superclass : #PureGitCommitish,
	#instVars : [
		'id',
		'author',
		'comment',
		'timestamp',
		'parentIds',
		'treeId'
	],
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #comparing }
PureGitCommit >> = anObject [
	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ self id = anObject id
]

{ #category : #accessing }
PureGitCommit >> author [
	^ author
]

{ #category : #accessing }
PureGitCommit >> author: aString [
	author := aString
]

{ #category : #accessing }
PureGitCommit >> changesToParent [
	^ self repository diffTool
		diffArgs: self changesToParentDiffArgs;
		diff
]

{ #category : #accessing }
PureGitCommit >> changesToParentDiffArgs [
	^ self isRoot
		ifTrue: [ { PureGitTree emptyTreeHash . self id } ]
		ifFalse: [ { self id , '^' . self id } ]
]

{ #category : #operations }
PureGitCommit >> checkout [
	self repository operations checkout: self id
]

{ #category : #accessing }
PureGitCommit >> comment [
	^ comment
]

{ #category : #accessing }
PureGitCommit >> comment: aMultilineString [
	comment := aMultilineString
]

{ #category : #accessing }
PureGitCommit >> commit [
	^ self
]

{ #category : #accessing }
PureGitCommit >> commitId [
	^ id
]

{ #category : #accessing }
PureGitCommit >> gitHubURL [
	| branch upstream remote gitUrl |
	(branch := self repository branch) ifNil: [ ^ nil ].
	(upstream := branch upstream) ifNil: [ ^ nil ].
	(remote := upstream remote) ifNil: [ ^ nil ].
	gitUrl := PureGitUrl with: remote url.
	gitUrl isNetworkUrl ifFalse: [ ^ nil ].
	gitUrl hostname = 'github.com' ifFalse: [ ^ nil ].
	^ 'https://github.com' asUrl
		/ gitUrl ownerName
		/ gitUrl repositoryName
		/ 'commit'
		/ self commitId
]

{ #category : #testing }
PureGitCommit >> hasParents [
	^ parentIds notEmpty
]

{ #category : #testing }
PureGitCommit >> hasSingleParent [
	^ self numberOfParents = 1
]

{ #category : #comparing }
PureGitCommit >> hash [
	^ self id hash
]

{ #category : #accessing }
PureGitCommit >> id [
	^ id
]

{ #category : #accessing }
PureGitCommit >> id: aString [
	id := aString
]

{ #category : #testing }
PureGitCommit >> isRoot [
	^ self hasParents not
]

{ #category : #accessing }
PureGitCommit >> numberOfParents [
	^ parentIds size
]

{ #category : #accessing }
PureGitCommit >> parent [
	^ self repository queries resolveCommit: self parentIds first
]

{ #category : #accessing }
PureGitCommit >> parentIds [
	^ parentIds
]

{ #category : #accessing }
PureGitCommit >> parentIds: aStringCollection [
	parentIds := aStringCollection
]

{ #category : #accessing }
PureGitCommit >> parents [
	^ self parentIds collect: [ :each | self repository queries resolveCommit: each ]
]

{ #category : #printing }
PureGitCommit >> printDetailsOn: stream [
	stream nextPutAll: self id
]

{ #category : #printing }
PureGitCommit >> printOn: stream [
	super printOn: stream.
	stream nextPut: $(.
	self printDetailsOn: stream.
	stream nextPut: $)
]

{ #category : #accessing }
PureGitCommit >> shortParentIds [
	^ parentIds collect: [ : each | each first: 7 ]
]

{ #category : #accessing }
PureGitCommit >> shortTreeId [
	^ treeId first: 7
]

{ #category : #accessing }
PureGitCommit >> timestamp [
	^ timestamp
]

{ #category : #accessing }
PureGitCommit >> timestamp: aZTimestamp [
	timestamp := aZTimestamp
]

{ #category : #accessing }
PureGitCommit >> tree [
	^ self repository resolveTree: self treeId
]

{ #category : #accessing }
PureGitCommit >> treeId [
	^ treeId
]

{ #category : #accessing }
PureGitCommit >> treeId: aString [
	treeId := aString
]
