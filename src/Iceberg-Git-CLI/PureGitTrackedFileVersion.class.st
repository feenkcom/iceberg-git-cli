Class {
	#name : #PureGitTrackedFileVersion,
	#superclass : #Object,
	#instVars : [
		'lines',
		'versionNumber',
		'commit',
		'trackedFile'
	],
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #accessing }
PureGitTrackedFileVersion >> commit [
	^ commit
]

{ #category : #accessing }
PureGitTrackedFileVersion >> commit: aCommit [ 
	commit := aCommit
]

{ #category : #accessing }
PureGitTrackedFileVersion >> lines [ 
	^ lines
]

{ #category : #accessing }
PureGitTrackedFileVersion >> lines: aCollectionOfTrackedLines [ 
	lines := aCollectionOfTrackedLines
]

{ #category : #printing }
PureGitTrackedFileVersion >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPut: $(;
		nextPutAll: self trackedFile path;
		space;
		nextPutAll: self commit shortId;
		nextPut: $)
]

{ #category : #accessing }
PureGitTrackedFileVersion >> trackedFile [
	^ trackedFile
]

{ #category : #accessing }
PureGitTrackedFileVersion >> trackedFile: aTrackedFile [ 
	trackedFile := aTrackedFile
]

{ #category : #accessing }
PureGitTrackedFileVersion >> versionNumber [
	^ versionNumber
]

{ #category : #accessing }
PureGitTrackedFileVersion >> versionNumber: aNumber [ 
	versionNumber := aNumber
]
