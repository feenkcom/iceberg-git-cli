"
I am an Announcement indicating a git repository has changed
"
Class {
	#name : #PureGitRepositoryModified,
	#superclass : #Announcement,
	#instVars : [
		'repository'
	],
	#category : #'Iceberg-Git-CLI-Pure-Core'
}

{ #category : #accessing }
PureGitRepositoryModified >> repository [
	^ repository
]

{ #category : #accessing }
PureGitRepositoryModified >> repository: aRepository [
	repository := aRepository
]
