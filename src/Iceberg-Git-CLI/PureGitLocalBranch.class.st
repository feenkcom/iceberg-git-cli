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
PureGitLocalBranch >> hasUpstream [
	^ self upstream notNil
]

{ #category : #testing }
PureGitLocalBranch >> isCurrent [
	^ self name = self repository currentBranchName
]

{ #category : #accessing }
PureGitLocalBranch >> upstream [
	| upstreamName |
	upstreamName := self repository upstreamNameForBranch: self name.
	upstreamName ifNil: [ ^ nil ].
	^ self repository remoteBranches
		detect: [ :each | each name = upstreamName ]
		ifNone: [ nil ]
]
