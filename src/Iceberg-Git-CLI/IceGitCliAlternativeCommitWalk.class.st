Class {
	#name : #IceGitCliAlternativeCommitWalk,
	#superclass : #IceAbstractCommitWalk,
	#instVars : [
		'args'
	],
	#category : #'Iceberg-Git-CLI-Core'
}

{ #category : #walking }
IceGitCliAlternativeCommitWalk >> commitsDo: aBlock [
	(self repository commits: args) do: aBlock
]

{ #category : #'instance creation' }
IceGitCliAlternativeCommitWalk >> fromBranch: aBranch [
	args := Array with: aBranch
]

{ #category : #'instance creation' }
IceGitCliAlternativeCommitWalk >> fromCommit: aCommit [
	args := Array with: aCommit id
]

{ #category : #'instance creation' }
IceGitCliAlternativeCommitWalk >> fromTag: aTag [
	args := Array with: aTag
]

{ #category : #'walk definition' }
IceGitCliAlternativeCommitWalk >> uptoCommit: aCommit [
	args := args copyWith: '^' , aCommit id
]
