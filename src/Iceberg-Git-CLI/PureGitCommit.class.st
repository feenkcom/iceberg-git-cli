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

{ #category : #accessing }
PureGitCommit >> author [
	^ author
]

{ #category : #accessing }
PureGitCommit >> author: aString [
	author := aString
]

{ #category : #accessing }
PureGitCommit >> changes [
	| diffArgs |
	diffArgs := { self id , '^' . self id }.
	^ { (self changesSummary: diffArgs) } , (self diff: diffArgs)
]

{ #category : #accessing }
PureGitCommit >> changesSummary: diffArgs [
	| numstat filesChangedCount additionsCount deletionsCount |
	numstat := self repository diff: { '--numstat' } , diffArgs.
	numstat := numstat collect: [ :each | | elements |
		elements := Character tab split: each.
		Array 
			with: (Integer readFrom: elements first ifFail: [ 0 ])
			with: (Integer readFrom: elements second ifFail: [ 0 ]) ].
	filesChangedCount := numstat size.
	additionsCount := numstat sum: #first.
	deletionsCount := numstat sum: #second.
	^ '{1} with {2} and {3.' format: {
		filesChangedCount pluralize: 'changed file'. 
		additionsCount pluralize: 'addition'.
		deletionsCount pluralize: 'deletion' }
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
PureGitCommit >> diff: diffArgs [
	^ self repository diff: { '--no-prefix' } , diffArgs
]

{ #category : #testing }
PureGitCommit >> hasParents [
	^ parentIds notEmpty
]

{ #category : #testing }
PureGitCommit >> hasSingleParent [
	^ self numberOfParents = 1
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
	^ self repository resolveCommit: self parentIds first
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
	^ self parentIds collect: [ :each | self repository resolveCommit: each ]
]

{ #category : #printing }
PureGitCommit >> printOn: stream [
	super printOn: stream.
	stream nextPut: $(.
	stream nextPutAll: self id.
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
