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
	^ self forwardOperation: #checkout: withArgument: commitish
]

{ #category : #operations }
PureGitAsyncOperations >> clone: gitUrl [
	^ self forwardOperation: #clone: withArgument: gitUrl
]

{ #category : #operations }
PureGitAsyncOperations >> commit: comment [
	^ self forwardOperation: #commit: withArgument: comment
]

{ #category : #operations }
PureGitAsyncOperations >> createBranch: branchName [
	^ self forwardOperation: #createBranch: withArgument: branchName
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
	^ self forwardOperation: #delete withArgument: nil
]

{ #category : #operations }
PureGitAsyncOperations >> fetch: args [
	^ self forwardOperation: #fetch: withArgument: args
]

{ #category : #private }
PureGitAsyncOperations >> forwardOperation: operation withArgument: arg [
	^ [ | result timeToRun |
	timeToRun := [ result := arg
				ifNil: [ delegate perform: operation ]
				ifNotNil: [ delegate perform: operation with: arg ] ] timeToRun.
	(PureGitOperationResult inRepository: self delegate repository)
		operation: operation;
		arg: arg;
		result: result;
		duration: timeToRun;
		yourself ] asAsyncPromise
]

{ #category : #operations }
PureGitAsyncOperations >> init [
	^ self forwardOperation: #init withArgument: nil
]

{ #category : #operations }
PureGitAsyncOperations >> merge: args [
	^ self forwardOperation: #merge: withArgument: args
]

{ #category : #operations }
PureGitAsyncOperations >> pull: args [
	^ self forwardOperation: #pull: withArgument: args
]

{ #category : #operations }
PureGitAsyncOperations >> push: args [
	^ self forwardOperation: #push: withArgument: args
]

{ #category : #operations }
PureGitAsyncOperations >> restore: filePath [
	^ self forwardOperation: #restore: withArgument: filePath
]

{ #category : #operations }
PureGitAsyncOperations >> stage: filePath [
	^ self forwardOperation: #stage: withArgument: filePath
]

{ #category : #operations }
PureGitAsyncOperations >> unstage: filePath [
	^ self forwardOperation: #unstage: withArgument: filePath
]
