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
	^ self upstreamName notNil
]

{ #category : #testing }
PureGitLocalBranch >> isCurrent [
	^ self name = self repository currentBranchName
]

{ #category : #accessing }
PureGitLocalBranch >> upstream [
	| upstreamName |
	upstreamName := self upstreamName.
	upstreamName ifNil: [ ^ nil ].
	^ self repository remoteBranches
		detect: [ :each | each name = upstreamName ]
		ifNone: [ nil ]
]

{ #category : #accessing }
PureGitLocalBranch >> upstreamName [
	^ self repository upstreamNameForBranch: self name
]

{ #category : #accessing }
PureGitLocalBranch >> upstreamRemoteName [
	^ (self repository upstreamNameForBranch: self name)
		ifNotNil: [ :fullName | ($/ split: fullName) first ]
]
