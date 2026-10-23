Class {
	#name : #PureGitExamples,
	#superclass : #Object,
	#category : #'Iceberg-Git-CLI-Pure-Core'
}

{ #category : #examples }
PureGitExamples >> currentIceGitCliPlatform [
	<gtExample>
	<return: #IceGitCliPlatform>
	^ IceGitCliPlatform current
]

{ #category : #'examples - commit store' }
PureGitExamples >> exampleCommitStoreEntriesConcurrent [
	<gtExample>
	| commit store sizes done |
	commit := GitCliStubCommit new.
	store := GitCliCommitStore on: commit.
	sizes := OrderedCollection new.
	done := Semaphore new.
	2 timesRepeat: [
		[ sizes add: store entries size. done signal ] fork.
		Processor yield ].
	done wait; wait.
	self assert: sizes asArray equals: #(1 1).
	self assert: commit repository lsTreeCalls equals: 1.
	^ store
]

{ #category : #'examples - commit store' }
PureGitExamples >> exampleEmptyPackageNamesNotCached [
	<gtExample>
	| commit |
	commit := GitCliStubCommit new.
	commit fetchedPackageNames: #().
	self assert: commit packageNames isEmpty.
	commit fetchedPackageNames: #('Foo').
	self assert: commit packageNames asArray equals: #('Foo').
	commit fetchedPackageNames: #('Bar').
	self assert: commit packageNames asArray equals: #('Foo').
	^ commit
]
