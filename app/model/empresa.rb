class Empresa
  include MongoMapper::Document
  
  key :cnpj, String, :unique => true
  key :cnpj_raiz, String
  key :cnae_codigo, String
  key :cnae_descricao, String
  key :nome_fantasia, String
  key :razao_social, String
  key :group_id, Integer
  
  many :reclamacao

  def self.by_cnpj(cnpj)
    if cnpj.size == 14
      reduce where(:cnpj => cnpj)
    elsif cnpj.size == 8
      reduce where(:cnpj_raiz => cnpj)
    else
      reduce where(:cnpj => Regexp.new('^' + cnpj))
    end
  end
  
  def group
    Empresa.where(:group_id => group_id).all
  end

  def stats
    EmpresaStats.find(self.group_id)
  end

  def self.by_top_reclamacoes 
    EmpresaStats.sort(:'value.total'.desc).limit(20).all 
  end
  
  def self.by_nome_fantasia(nome_fantasia)
    reduce where(:nome_fantasia => Regexp.new('^' + nome_fantasia))
  end

  def self.search(cnpj, nome_fantasia)
    if(cnpj && nome_fantasia)
      reduce where(:cnpj => Regexp.new('^'+cnpj)).where(:nome_fantasia => Regexp.new('^' + nome_fantasia))
    elsif(cnpj)
      by_cnpj(cnpj)
    else
      by_nome_fantasia(nome_fantasia)
    end
  end

  def similar_to(other)
    same_cnpj = self.cnpj_raiz == other.cnpj_raiz 
    similar_name = (self.nome_fantasia.include?(other.nome_fantasia) || other.nome_fantasia.include?(self.nome_fantasia)) && self.cnae_codigo == other.cnae_codigo && self.nome_fantasia != 'NULL' && other.nome_fantasia != 'NULL'
    same_cnpj || similar_name
  end

  def self.reduce(empresas)
   empresas.all.uniq
  end
  
  def hash
    self.group_id.hash
  end
  
  def eql?(other)
    self == other
  end
  
  def ==(other)
    self.group_id == other.group_id
  end
end
