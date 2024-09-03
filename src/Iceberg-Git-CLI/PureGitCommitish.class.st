Class {
	#name : #PureGitCommitish,
	#superclass : #PureGitRepositoryObject,
	#category : #'Iceberg-Git-CLI-Pure'
}

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
PureGitCommitish >> shortCommitId [
	^ self commitId first: 7
]
