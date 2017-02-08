require 'singleton'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class ModelBase

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{self.my_table}
      WHERE
        id = ?
    SQL
    data.map { |datum| self.new(datum) }
  end

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM #{self.my_table}")
    data.map { |datum| self.new(datum) }
  end

  def create
    if !self.id
      QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @author_id)
        INSERT INTO
          questions (title, body, author_id)
        VALUES
          (?, ?, ?)
      SQL
      @id = QuestionsDatabase.instance.last_insert_row_id
    else
      self.update
    end
  end

  def update
    raise "#{self} not in database" unless self.id
    QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @author_id, @id)
      UPDATE
        questions
      SET
        title = ?, body = ?, author_id = ?
      WHERE
        id = ?
    SQL
  end

end


class Questions < ModelBase
  attr_accessor :title, :author_id, :body, :id

  def self.find_by_author_id(author_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        author_id = ?
    SQL
    data.map { |datum| Questions.new(datum) }
  end


  def self.most_followed(n)
    Question_Follows.most_followed_questions(n)
  end

  def self.most_liked(n)
    Question_likes.most_liked_questions(n)
  end

  def self.my_table
    'questions'
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end


  def followers
    Question_Follows.followers_for_question_id(@id)
  end

  def author
    Users.find_by_id(@author_id)
  end

  def replies
    Replies.find_by_question_id(@id)
  end

  # def create
  #   if !@id
  #     QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @author_id)
  #       INSERT INTO
  #         questions (title, body, author_id)
  #       VALUES
  #         (?, ?, ?)
  #     SQL
  #     @id = QuestionsDatabase.instance.last_insert_row_id
  #   else
  #     self.update
  #   end
  # end
  #
  # def update
  #   raise "#{self} not in database" unless @id
  #   QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @author_id, @id)
  #     UPDATE
  #       questions
  #     SET
  #       title = ?, body = ?, author_id = ?
  #     WHERE
  #       id = ?
  #   SQL
  # end

  def likers
    Question_likes.likers_for_question_id(@id)
  end

  def num_likes
    Question_likes.num_likes_for_question_id(@id)
  end


end
