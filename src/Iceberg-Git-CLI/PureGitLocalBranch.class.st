Class {
	#name : #PureGitLocalBranch,
	#superclass : #PureGitBranch,
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #accessing }
PureGitLocalBranch >> branchType [
	^ #local
]