"
I exist in the context of a PureGitRepository
"
Class {
	#name : #PureGitRepositoryObject,
	#superclass : #Object,
	#instVars : [
		'repository'
	],
	#category : #'Iceberg-Git-CLI-Pure-Core'
}

{ #category : #'instance creation' }
PureGitRepositoryObject class >> inRepository: aRepository [
	^ self new
		repository: aRepository;
		yourself
]

{ #category : #accessing }
PureGitRepositoryObject >> repository [
	^ repository
]

{ #category : #accessing }
PureGitRepositoryObject >> repository: aRepository [
	repository := aRepository
]
