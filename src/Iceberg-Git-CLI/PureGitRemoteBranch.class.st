Class {
	#name : #PureGitRemoteBranch,
	#superclass : #PureGitBranch,
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #accessing }
PureGitRemoteBranch >> branchType [
	^ #remote
]
