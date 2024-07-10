Class {
	#name : #BaselineOfIcebergGitCli,
	#superclass : #BaselineOf,
	#category : #BaselineOfIcebergGitCli
}

{ #category : #baseline }
BaselineOfIcebergGitCli >> baseline: spec [
	<baseline>
	^ spec for: #common do: [ 
		spec
			baseline: 'GToolkitExternalProcess'
			with: [ spec repository: 'github://feenkcom/gtoolkit-external-process:main/src' ].
			
		"spec
			baseline: 'Iceberg'
			with: [ spec repository: 'github://pharo-vcs/Iceberg:v2.2.2' ]."

		spec
			package: 'Iceberg-Git-CLI'
			with: [ spec requires: #("'Iceberg'" 'GToolkitExternalProcess') ] ]
]
