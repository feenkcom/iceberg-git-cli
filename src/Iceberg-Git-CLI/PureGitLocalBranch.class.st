"
I am a local git branch.
"
Class {
	#name : #PureGitLocalBranch,
	#superclass : #PureGitBranch,
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #accessing }
PureGitLocalBranch >> branchType [
	^ #local
]

{ #category : #testing }
PureGitLocalBranch >> isCurrent [
	^ self name = self repository currentBranchName
]
