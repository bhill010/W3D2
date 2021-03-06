require_relative 'questions'

class Replies < ModelBase
  attr_accessor :body, :question_id, :user_id, :reply_id, :id

  def self.find_by_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL,user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?

    SQL
    data.map { |datum| Replies.new(datum) }
  end

  def self.find_by_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL,question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?

    SQL
    data.map { |datum| Replies.new(datum) }
  end

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM replies")
    data.map { |datum| Replies.new(datum) }
  end



  def initialize(options)
    @id = options['id']
    @body = options['body']
    @question_id = options['question_id']
    @user_id = options['user_id']
    @reply_id = options['reply_id']
  end

  def author
    Users.find_by_id(@user_id)
  end

  def question
    Questions.find_by_id(@question_id)
  end

  def parent_reply
    raise "There is no parent" if self.reply_id.nil?
    Replies.find_by_id(@reply_id)
  end

  def child_replies
    data = QuestionsDatabase.instance.execute(<<-SQL, @id)
      SELECT
        *
      FROM
        replies
      WHERE
        reply_id = ?
    SQL
    raise "No child replies" if data.empty?
    data.map { |datum| Replies.new(datum) }
  end

  def create
    if !@id
      QuestionsDatabase.instance.execute(<<-SQL, @body, @question_id, @user_id, @reply_id)
        INSERT INTO
          replies (body, question_id, user_id, reply_id)
        VALUES
          (?, ?, ?, ?)
      SQL
      @id = QuestionsDatabase.instance.last_insert_row_id
    else
      self.update
    end
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @body, @question_id, @user_id, @reply_id, @id)
      UPDATE
        replies
      SET
        body = ?, question_id = ?, user_id = ?, reply_id = ?
      WHERE
        id = ?
    SQL
  end

end
