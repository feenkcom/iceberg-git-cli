Class {
	#name : #PureGitCommitish,
	#superclass : #Object,
	#instVars : [
		'repository'
	],
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #'instance creation' }
PureGitCommitish class >> inRepository: aRepository [
	^ self new
		repository: aRepository;
		yourself
]

{ #category : #accessing }
PureGitCommitish >> commit [
	self subclassResponsibility
]

{ #category : #accessing }
PureGitCommitish >> commitId [
	self subclassResponsibility
]

{ #category : #accessing }
PureGitCommitish >> log [
	^ self repository logFrom: self commitId
]

{ #category : #accessing }
PureGitCommitish >> repository [
	^ repository
]

{ #category : #accessing }
PureGitCommitish >> repository: aRepository [
	repository := aRepository
]
