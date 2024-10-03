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

{ #category : #operations }
PureGitLocalBranch >> checkout [
	self repository operations checkout: self name
]

{ #category : #testing }
PureGitLocalBranch >> hasUpstream [
	^ self upstreamName notNil
]

{ #category : #accessing }
PureGitLocalBranch >> incomingCommits [
	| upstream |
	upstream := self upstream.
	(upstream isNil or: [ self commit = upstream commit ])
		ifTrue: [ ^ #() asAsyncStream ].
	^ self repository queries 
		logFrom: self name , '..' , upstream remote name
		for: nil
]

{ #category : #testing }
PureGitLocalBranch >> isCurrent [
	| currentBranchName |
	currentBranchName := self repository queries currentBranchName.
	^ self name = currentBranchName
		or: [ currentBranchName isEmpty
				and: [ self name includesSubstring: 'HEAD detached' ] ]
]

{ #category : #accessing }
PureGitLocalBranch >> outgoingCommits [
	| upstream |
	upstream := self upstream.
	(upstream isNil or: [ self commit = upstream commit ])
		ifTrue: [ ^ #() asAsyncStream ].
	^ self repository queries 
		logFrom: upstream remote name , '..' , self name
		for: nil
]

{ #category : #accessing }
PureGitLocalBranch >> upstream [
	| upstreamName |
	upstreamName := self upstreamName.
	upstreamName ifNil: [ ^ nil ].
	^ self repository queries remoteBranches
		detect: [ :each | each name = upstreamName ]
		ifNone: [ nil ]
]

{ #category : #accessing }
PureGitLocalBranch >> upstreamName [
	^ self repository queries upstreamNameForBranch: self name
]

{ #category : #accessing }
PureGitLocalBranch >> upstreamRemoteName [
	^ self upstreamName
		ifNotNil: [ :fullName | ($/ split: fullName) first ]
]
