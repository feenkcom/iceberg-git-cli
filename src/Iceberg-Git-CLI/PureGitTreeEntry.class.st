Class {
	#name : #PureGitTreeEntry,
	#superclass : #PureGitRepositoryObject,
	#instVars : [
		'name',
		'type',
		'mode',
		'id'
	],
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #accessing }
PureGitTreeEntry >> id [
	^ id
]

{ #category : #accessing }
PureGitTreeEntry >> id: anObject [
	id := anObject
]

{ #category : #accessing }
PureGitTreeEntry >> mode [
	^ mode
]

{ #category : #accessing }
PureGitTreeEntry >> mode: anObject [
	mode := anObject
]

{ #category : #accessing }
PureGitTreeEntry >> name [
	^ name
]

{ #category : #accessing }
PureGitTreeEntry >> name: anObject [
	name := anObject
]

{ #category : #printing }
PureGitTreeEntry >> printOn: stream [
	super printOn: stream.
	stream nextPut: $(.
	name ifNotNil: [ stream nextPutAll: name ].
	stream nextPut: $)
]

{ #category : #accessing }
PureGitTreeEntry >> resolve [
	type = #blob ifTrue: [ ^ repository resolveBlob: id ].
	type = #tree ifTrue: [ ^ repository resolveTree: id ].
	self
		assert: (#(blob tree) includes: type)
		description: 'Unknow git tree entry type'
]

{ #category : #accessing }
PureGitTreeEntry >> type [
	^ type
]

{ #category : #accessing }
PureGitTreeEntry >> type: anObject [
	type := anObject
]
