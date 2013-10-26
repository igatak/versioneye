require 'cocoapods-core'

class PodSpecParser < CommonParser

  # Parser for CocoaPods podspec

  @@language  = Product::A_LANGUAGE_OBJECTIVEC
  @@prod_type = Project::A_TYPE_COCOAPODS


  def parse ( file )
    podspec = load_spec file
    
    product = get_product podspec

    update_product product, podspec
  end


  def load_spec file
    Pod::Spec.from_file(file)
  end


  def get_product podspec
    product = Product.find_by_lang_key(Product::A_LANGUAGE_OBJECTIVEC, podspec.name)

    unless product
      product = Product.new
    end

    product
  end


  def update_product product, podspec

    prod_key = podspec.name
    product.update_attributes({
      :reindex       => true,
      :prod_key      => prod_key,
      :name          => podspec.name,
      :name_downcase => podspec.name.downcase,
      :language      => @@language,
      :prod_type     => @@prod_type,
    })

    product.description = podspec.summary

    product.dependencies = dependencies podspec

    product.versions.push(version podspec)
    product.repository    = repository podspec
    product.developers    = developers podspec
    product.versionlinks  = versionlinks podspec
  end


  def dependencies podspec
    deps = []
    podspec.dependencies.each do |pod_dep|
      deps << Dependency.new({
        :language      => @@language,
        :prod_type     => @@prod_type,
        :prod_key      => podspec.name,
        :prod_version  => podspec.version,

        :dep_prod_key  => pod_dep.to_s, 
        :version       => pod_dep.version,
        })
      end
    deps
  end


  def version podspec
    Version.new({
      :version => podspec.version, 
      :license => podspec.license[:type],
      # TODO get release date through github api
      # repository => version tag
      #:released_at =>
      })
  end


  def repository podspec
    Repository.new({
      :repo_type => 'git',
      :repo_source => podspec.source[:git]
      })
  end


  def developers podspec
    developers = []


    podspec.authors.each do |name, email|
      developers << Developer.new({
        :language => @@language,
        :prod_key => podspec.name,
        :version  => podspec.version,

        :name     => name,
        :email    => email,
        })
    end

    developers
  end

  def versionlinks podspec
    [Versionlink.new({
      :name => 'Homepage',
      :link => podspec.homepage,
      })]
  end

end
