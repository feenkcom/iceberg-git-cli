Class {
	#name : #PureGitDiffTool,
	#superclass : #PureGitRepositoryObject,
	#instVars : [
		'diffArgs'
	],
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #accessing }
PureGitDiffTool >> diff [
	^ self repository diff: { '--no-prefix' } , diffArgs
]

{ #category : #accessing }
PureGitDiffTool >> diffArgs [
	^ diffArgs
]

{ #category : #accessing }
PureGitDiffTool >> diffArgs: aCollection [
	diffArgs := aCollection
]

{ #category : #accessing }
PureGitDiffTool >> diffSummary [
	| numstat filesChangedCount additionsCount deletionsCount |
	numstat := self repository diff: { '--numstat' } , diffArgs.
	filesChangedCount := numstat size.
	filesChangedCount = 0 
		ifTrue: [ ^ 'no changes' ].
	numstat := numstat collect: [ :each | | elements |
		elements := Character tab split: each.
		Array 
			with: (Integer readFrom: elements first ifFail: [ 0 ])
			with: (Integer readFrom: elements second ifFail: [ 0 ]) ].
	additionsCount := numstat sum: #first.
	deletionsCount := numstat sum: #second.
	^ '{1} with {2} and {3}.' format: {
		filesChangedCount pluralize: 'changed file'. 
		additionsCount pluralize: 'addition'.
		deletionsCount pluralize: 'deletion' }
]