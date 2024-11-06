"
I am a local git branch.
"
Class {
	#name : #PureGitLocalBranch,
	#superclass : #PureGitBranch,
	#category : #'Iceberg-Git-CLI-Pure-Core'
}

{ #category : #accessing }
PureGitLocalBranch >> branchType [
	^ #local
]

{ #category : #operations }
PureGitLocalBranch >> checkout [
	self repository operations checkout: self name
]

{ #category : #accessing }
PureGitLocalBranch >> commitsAhead [
	^ self outgoingCommits toArray wait size
]

{ #category : #accessing }
PureGitLocalBranch >> commitsBehind [
	^ self incomingCommits toArray wait size
]

{ #category : #testing }
PureGitLocalBranch >> hasUpstream [
	^ self upstreamName notNil
]

{ #category : #accessing }
PureGitLocalBranch >> incomingCommits [
	| upstream spec |
	upstream := self upstream.
	(upstream isNil or: [ self commit = upstream commit ])
		ifTrue: [ ^ #() asAsyncStream ].
	spec := self name , '..' , upstream remote name.
	^ self repository queries log: {spec}
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
	| upstream spec |
	upstream := self upstream.
	(upstream isNil or: [ self commit = upstream commit ])
		ifTrue: [ ^ #() asAsyncStream ].
	spec := upstream remote name , '..' , self name.
	^ self repository queries log: { spec }
]

{ #category : #operations }
PureGitLocalBranch >> push [
	self repository operations push: { self upstreamRemoteName . self name }
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
