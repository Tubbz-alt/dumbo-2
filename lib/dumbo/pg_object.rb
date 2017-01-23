module Dumbo
  class PgObject
    attr_reader :oid

    class << self
      attr_accessor :identifier

      def identfied_by(*args)
        self.identifier = args
      end
    end

    def initialize(oid)
      @oid = oid
      load_attributes
    end

    def identifier
      self.class.identifier
    end

    def identify
      identifier.map { |a| public_send a }
    end

    def get(type = nil)
      case type
      when 'function', 'pg_proc'
        Function.new(oid).get
      when 'cast', 'pg_cast'
        Cast.new(oid).get
      when 'operator', 'pg_operator'
        Operator.new(oid).get
      when 'type', 'pg_type'
        Type.new(oid).get
      else
        load_attributes
        self
      end
    end

    def load_attributes
    end

    def migrate_to(other)
      fail 'Not the Same Objects!' if other.identify != identify

      if other.to_sql != to_sql
        <<-SQL.gsub(/^ {8}/, '')
        #{drop}
        #{other.to_sql}
        SQL
      end
    end
  end
end
