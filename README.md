# pipeline-mod-nota
Nota specific modules for the DAISY Pipeline 2

## Release procedure
- View changes since previous release and update version number according to semantic versioning.

  ```sh
  git diff v1.0.0...HEAD
  VERSION=1.0.1
  ```

- Create a release branch.

  ```sh
  git checkout -b release/${VERSION}
  ```
  
- Resolve snapshot dependencies and commit.
- Set the version in pom.xml to `${VERSION}-SNAPSHOT` and commit.
- Make release notes and commit. (View changes since previous release with `git diff v1.1.0...HEAD`
  and look for relevant Github issues on [https://github.com/search](https://github.com/search))
- Perform the release with Maven.

```sh
  mvn clean release:clean release:prepare -DpushChanges=false
  mvn release:perform -DlocalCheckout=true
```

- Push and make a pull request (for turning an existing issue into a PR use the `-i <issueno>` switch).

  ```sh
  git push origin release/${VERSION}:release/${VERSION}
  hub pull-request -b snaekobbi:master -h snaekobbi:release/${VERSION} -m "Release version ${VERSION}"
  ```
  
- Stage the artifact on https://oss.sonatype.org and comment on pull request.

  ```sh
  ghi comment -m staged ${ISSUE_NO}
  ```
  
- Test and stage all projects that depend on this release before continuing.

- Release the artifact on https://oss.sonatype.org  and close pull request.

  ```sh
  ghi comment --close -m released ${ISSUE_NO}
  ```
  
- Push the tag.

  ```sh
  git push origin v${VERSION}
  ```
  
- Add the release notes to http://github.com/snaekobbi/pipeline-mod-nota/releases/v${VERSION}.

## Testing the packages before running the docker

It requires maven installed and the solution is designed for Java 11.

To see if all the packages download and the project builds first remove the repository folder in your homefolder/.mvn then run
`mvn clean package -DskipTests`
It clears any compiled .java sources and downloads all the packages again.

## Handling HTTPS requirements by maven.

Many packages are still depending on repositories using http and will be rejected when attempting to fetch from these.
To avoid dependency issues a way forward is to add the http repository as a https repository.
This way, it will attempt to fetch from the http repository and fail and then attempt to fetch from the https repository and succeed (hopefully).

To accomplish this, inspect the failing package and its repository.
Example of a failing package: `Transfer failed for http://repo.maven.apache.org/maven2/org/daisy/pipeline/framework-bom/1.11.2/framework-bom-1.11.2.pom 501 HTTPS Required`
The repository is: `repo.maven.apache.org/maven2/`
The package path is: `org/daisy/pipeline/framework-bom/1.11.2/framework-bom-1.11.2.pom`
And the error is 501, HTTPS Required.

To avoid this issue for this package and any other package resolving from this repository you need to add a repository and a plugin repository to the POM.xml file of the project inside the `project` tag.

```xml
<repositories>
	<repository>
    	<id>repo.maven.apache.org-https</id> <!-- Can be anything, for reference and must be unique -->
        <name>repo.maven.apache.org HTTPS</name> <!-- Can be anything, for reference -->
        <url>https://repo.maven.apache.org/maven2/</url> <!-- The same repository as the one failing, except it uses https instead of http -->
	</repository>
</repositories>
```

```xml
<pluginRepositories>
	<pluginRepository>
		<id>repo.maven.apache.org-https</id> <!-- Can be anything, for reference and must be unique -->
		<name>repo.maven.apache.org HTTPS</name> <!-- Can be anything, for reference -->
		<url>https://repo.maven.apache.org/maven2/</url> <!-- The same repository as the one failing, except it uses https instead of http -->
	</pluginRepository>
</pluginRepositories>
```

The tags `repositories` and `pluginRepositories` just sums up all the various added repositories and pluginRepositories.