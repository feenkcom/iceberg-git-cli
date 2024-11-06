"
I am a remote git branch.

I exist in a remote.
"
Class {
	#name : #PureGitRemoteBranch,
	#superclass : #PureGitBranch,
	#category : #'Iceberg-Git-CLI-Pure-Core'
}

{ #category : #accessing }
PureGitRemoteBranch >> branchType [
	^ #remote
]

{ #category : #accessing }
PureGitRemoteBranch >> remote [
	^ self repository queries remotes
		detect: [ :each | each name = self remoteName ]
		ifNone: [ nil ]
]

{ #category : #accessing }
PureGitRemoteBranch >> remoteName [
	^ ($/ split: self name) first
]

{ #category : #accessing }
PureGitRemoteBranch >> shortName [
	^ ($/ split: self name) second
]

{ #category : #accessing }
PureGitRemoteBranch >> trackers [
	^ self repository queries localBranches
		select: [ :each | each upstreamName = self name ]
]
