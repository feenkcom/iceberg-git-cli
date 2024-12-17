"
I run operations on a repository that change its state
"
Class {
	#name : #PureGitOperations,
	#superclass : #PureGitCommandLineInterface,
	#category : #'Iceberg-Git-CLI-Pure-Core'
}

{ #category : #private }
PureGitOperations >> announceRepositoryModified [
	self repository announceRepositoryModified
]

{ #category : #accessing }
PureGitOperations >> async [
	^ PureGitAsyncOperations new
		delegate: self;
		yourself
]

{ #category : #operations }
PureGitOperations >> checkout: commitish [
	self runGitWithArgs: { 'checkout' . commitish }.
	self announceRepositoryModified
]

{ #category : #operations }
PureGitOperations >> clone: gitUrl [
	self runGitWithArgs: { 'clone' . gitUrl . '.' }.
	self announceRepositoryModified
]

{ #category : #operations }
PureGitOperations >> commit: comment [
	| args |
	args := OrderedCollection with: 'commit'.
	IceGitCliPlatform current signCommits
		ifTrue: [ args add: '-S' ].
	args add: '-m'; add: comment withUnixLineEndings.
	self runGitWithArgs: args.
	self announceRepositoryModified
]

{ #category : #operations }
PureGitOperations >> createBranch: branchName [
	| newBranch |
	self runGitWithArgs: { 'branch' . branchName }.
	newBranch := self repository queries localBranches 
		detect: [ :branch | branch name = branchName ].
	newBranch checkout. "will trigger announceRepositoryModified"
	^ newBranch
]

{ #category : #operations }
PureGitOperations >> delete [
	self repository exists
		ifTrue: [ self repository location ensureDeleteAll.
			self repository deleted.
			self announceRepositoryModified ]
]

{ #category : #operations }
PureGitOperations >> fetch: args [
	self runGitWithArgs: #('fetch') , args.
	self announceRepositoryModified
]

{ #category : #operations }
PureGitOperations >> init [
	self runGitWithArgs: { 'init' }.
	self announceRepositoryModified
]

{ #category : #operations }
PureGitOperations >> merge: args [
	self runGitWithArgs: #('merge') , args.
	self announceRepositoryModified
]

{ #category : #operations }
PureGitOperations >> pull: args [
	self runGitWithArgs: #('pull') , args.
	self announceRepositoryModified
]

{ #category : #operations }
PureGitOperations >> push: args [
	self runGitWithArgs: #('push') , args.
	self announceRepositoryModified
]

{ #category : #operations }
PureGitOperations >> restore: filePath [
	self runGitWithArgs: { 'restore' . '--worktree' . filePath }.
	self announceRepositoryModified
]

{ #category : #operations }
PureGitOperations >> stage: filePath [
	self runGitWithArgs: { 'add' . filePath }.
	self announceRepositoryModified
]

{ #category : #operations }
PureGitOperations >> unstage: filePath [
	self runGitWithArgs: { 'restore' . '--staged' . filePath }.
	self announceRepositoryModified
]
