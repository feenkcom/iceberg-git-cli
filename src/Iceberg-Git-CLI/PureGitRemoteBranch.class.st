"
I am a remote git branch.
"
Class {
	#name : #PureGitRemoteBranch,
	#superclass : #PureGitBranch,
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #accessing }
PureGitRemoteBranch >> branchType [
	^ #remote
]

{ #category : #accessing }
PureGitRemoteBranch >> remote [
	^ self repository remotes
		detect: [ :each | each name = self remoteName ]
		ifNone: [ nil ]
]

{ #category : #accessing }
PureGitRemoteBranch >> remoteName [
	^ ($/ split: self name) first
]
