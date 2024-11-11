"
I wrap a PureGitOperations instance to which I delegate operations as async promises that execute concurrently
"
Class {
	#name : #PureGitAsyncOperations,
	#superclass : #Object,
	#instVars : [
		'delegate'
	],
	#category : #'Iceberg-Git-CLI-Pure-Core'
}

{ #category : #operations }
PureGitAsyncOperations >> checkout: commitish [
	^ self forwardOperation: #checkout: withArguments: { commitish }
]

{ #category : #operations }
PureGitAsyncOperations >> clone: gitUrl [
	^ self forwardOperation: #clone: withArguments: { gitUrl }
]

{ #category : #operations }
PureGitAsyncOperations >> commit: comment [
	^ self forwardOperation: #commit: withArguments: { comment }
]

{ #category : #operations }
PureGitAsyncOperations >> createBranch: branchName [
	^ self forwardOperation: #createBranch: withArguments: { branchName }
]

{ #category : #accessing }
PureGitAsyncOperations >> delegate [
	^ delegate
]

{ #category : #accessing }
PureGitAsyncOperations >> delegate: aPureGitOperations [
	delegate := aPureGitOperations
]

{ #category : #operations }
PureGitAsyncOperations >> delete [
	^ self forwardOperation: #delete withArguments: #()
]

{ #category : #operations }
PureGitAsyncOperations >> fetch: args [
	^ self forwardOperation: #fetch: withArguments: args
]

{ #category : #private }
PureGitAsyncOperations >> forwardOperation: operation withArguments: args [
	^ [ | result timeToRun |
	timeToRun := [ result := delegate perform: operation withArguments: args ]
			timeToRun.
	(PureGitOperationResult inRepository: self delegate repository)
		operation: operation;
		args: args;
		result: result;
		duration: timeToRun;
		yourself ] asAsyncPromise
]

{ #category : #operations }
PureGitAsyncOperations >> init [
	^ self forwardOperation: #init withArguments: #()
]

{ #category : #operations }
PureGitAsyncOperations >> merge: args [
	^ self forwardOperation: #merge: withArguments: args
]

{ #category : #operations }
PureGitAsyncOperations >> pull: args [
	^ self forwardOperation: #pull: withArguments: args
]

{ #category : #operations }
PureGitAsyncOperations >> push: args [
	^ self forwardOperation: #push: withArguments: args
]

{ #category : #operations }
PureGitAsyncOperations >> restore: filePath [
	^ self forwardOperation: #restore: withArguments: { filePath }
]

{ #category : #operations }
PureGitAsyncOperations >> stage: filePath [
	^ self forwardOperation: #stage: withArguments: { filePath }
]

{ #category : #operations }
PureGitAsyncOperations >> unstage: filePath [
	^ self forwardOperation: #unstage: withArguments: { filePath }
]
