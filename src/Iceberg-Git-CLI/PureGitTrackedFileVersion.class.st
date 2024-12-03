"
I model a tracked file at a specific version/commit within the context of its full history.
I hold the file's contents as tracked lines at that specific point in time/version/commit.
"
Class {
	#name : #PureGitTrackedFileVersion,
	#superclass : #Object,
	#instVars : [
		'lines',
		'versionNumber',
		'commit',
		'trackedFile'
	],
	#category : #'Iceberg-Git-CLI-Pure-Analysis'
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
