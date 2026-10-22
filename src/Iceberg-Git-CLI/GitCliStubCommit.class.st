"
Stub commit for examples. It answers a {{gtClass:GitCliStubRepository}} and a configurable result of {{gtMethod:GitCliStubCommit>>#fetchPackageNames}}, so that the caching in {{gtMethod:IceGitCliCommit>>#packageNames}} can be tested without a real git repository.
"
Class {
	#name : #GitCliStubCommit,
	#superclass : #IceGitCliCommit,
	#instVars : [
		'stubRepository',
		'fetchedPackageNames'
	],
	#category : #'Iceberg-Git-CLI'
}

{ #category : #private }
GitCliStubCommit >> fetchPackageNames [
	^ fetchedPackageNames
]

{ #category : #accessing }
GitCliStubCommit >> fetchedPackageNames: aCollection [
	fetchedPackageNames := aCollection
]

{ #category : #accessing }
GitCliStubCommit >> repository [
	^ stubRepository ifNil: [ stubRepository := GitCliStubRepository new ]
]
