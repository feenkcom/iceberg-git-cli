"
I run operations on a repository that change its state
"
Class {
	#name : #PureGitOperations,
	#superclass : #PureGitCommandLineInterface,
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #private }
PureGitOperations >> announceRepositoryModified [
	self repository announceRepositoryModified
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
	self runGitWithArgs: { 'commit' . '-m' . comment }.
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
PureGitOperations >> init [
	self runGitWithArgs: { 'init' }.
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