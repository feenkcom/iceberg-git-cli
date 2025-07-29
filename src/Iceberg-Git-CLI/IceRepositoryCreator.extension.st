Extension { #name : #IceRepositoryCreator }

{ #category : #'*Iceberg-Git-CLI' }
IceRepositoryCreator >> repository [

	^ repository ifNil: [ repository := IceRepository repositoryClass new ]
]
