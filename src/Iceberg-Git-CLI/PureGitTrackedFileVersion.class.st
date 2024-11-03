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

{ #category : #operations }
PureGitTrackedFileVersion >> commit [
	^ commit
]

{ #category : #operations }
PureGitTrackedFileVersion >> commit: aCommit [ 
	commit := aCommit
]

{ #category : #'as yet unclassified' }
PureGitTrackedFileVersion >> lines [ 
	^ lines
]

{ #category : #operations }
PureGitTrackedFileVersion >> lines: aCollectionOfTrackedLines [ 
	lines := aCollectionOfTrackedLines
]

{ #category : #operations }
PureGitTrackedFileVersion >> trackedFile: aTrackedFile [ 
	trackedFile := aTrackedFile
]

{ #category : #'as yet unclassified' }
PureGitTrackedFileVersion >> versionNumber [
	^ versionNumber
]

{ #category : #operations }
PureGitTrackedFileVersion >> versionNumber: aNumber [ 
	versionNumber := aNumber
]
