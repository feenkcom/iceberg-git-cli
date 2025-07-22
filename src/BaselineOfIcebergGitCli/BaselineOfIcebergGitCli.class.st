Class {
	#name : #BaselineOfIcebergGitCli,
	#superclass : #BaselineOf,
	#category : #BaselineOfIcebergGitCli
}

{ #category : #baseline }
BaselineOfIcebergGitCli >> baseline: spec [
	<baseline>
	spec for: #'common' do: [
		spec
			baseline: 'GToolkitExternalProcess' with: [
				spec repository: 'github://feenkcom/gtoolkit-external-process:v0.6.142/src' ].

		spec package: 'Iceberg-Git-CLI' with: [
			spec requires: #(#GToolkitExternalProcess) ].
	]
]
