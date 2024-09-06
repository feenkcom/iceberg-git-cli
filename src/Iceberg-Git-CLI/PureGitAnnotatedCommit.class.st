"
I wrap a commit and hold resolved parents as well as branches and tags pointing to it.
"
Class {
	#name : #PureGitAnnotatedCommit,
	#superclass : #Object,
	#instVars : [
		'commit',
		'parents',
		'labels'
	],
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #accessing }
PureGitAnnotatedCommit >> addLabel: labelString [
	labels isEmpty
		ifTrue: [ labels := OrderedCollection new ].
	labels add: labelString
]

{ #category : #accessing }
PureGitAnnotatedCommit >> author [
	^ commit author
]

{ #category : #accessing }
PureGitAnnotatedCommit >> comment [
	^ commit comment
]

{ #category : #accessing }
PureGitAnnotatedCommit >> commit [
	^ commit
]

{ #category : #accessing }
PureGitAnnotatedCommit >> commit: anObject [
	commit := anObject
]

{ #category : #accessing }
PureGitAnnotatedCommit >> id [
	^ commit id
]

{ #category : #initialization }
PureGitAnnotatedCommit >> initialize [
	super initialize.
	labels := #()
]

{ #category : #accessing }
PureGitAnnotatedCommit >> labels [
	^ labels
]

{ #category : #accessing }
PureGitAnnotatedCommit >> labels: anObject [
	labels := anObject
]

{ #category : #accessing }
PureGitAnnotatedCommit >> parentIds [
	^ commit parentIds
]

{ #category : #accessing }
PureGitAnnotatedCommit >> parents [
	^ parents
]

{ #category : #accessing }
PureGitAnnotatedCommit >> parents: anObject [
	parents := anObject
]

{ #category : #accessing }
PureGitAnnotatedCommit >> shortId [
	^ commit shortCommitId
]

{ #category : #accessing }
PureGitAnnotatedCommit >> timestamp [
	^ commit timestamp
]
