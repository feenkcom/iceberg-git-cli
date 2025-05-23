"
I am an abstraction of things that can be considered a commit.
"
Class {
	#name : #PureGitCommitish,
	#superclass : #PureGitRepositoryObject,
	#category : #'Iceberg-Git-CLI-Pure-Core'
}

{ #category : #operations }
PureGitCommitish >> checkout [
	self subclassResponsibility
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
	^ self repository queries log: { self commitId }
]

{ #category : #accessing }
PureGitCommitish >> shortCommitId [
	^ self commitId first: 7
]
