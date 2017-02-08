require_relative 'questions'

class Users < ModelBase
  attr_accessor :fname, :id, :lname

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM users")
    data.map { |datum| Users.new(datum) }
  end


  def self.find_by_name(fname, lname)
    data = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    data.map { |datum| Users.new(datum) }
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def authored_questions
    Questions.find_by_author_id(@id)
  end

  def followed_questions
    Question_Follows.followed_questions_for_user_id(@id)
  end

  def authored_replies
    Replies.find_by_user_id(@id)
  end

  def create
    if !@id
      QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname)
        INSERT INTO
          users (fname, lname)
        VALUES
          (?, ?)
      SQL
      @id = QuestionsDatabase.instance.last_insert_row_id
    else
      self.update
    end
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname, @id)
      UPDATE
        users
      SET
        fname = ?, lname = ?
      WHERE
        id = ?
    SQL
  end

  def liked_question
    Question_likes.liked_questions_for_user_id(@id)
  end

  def average_karma
    ans = QuestionsDatabase.instance.execute(<<-SQL, @id)
    SELECT
      COUNT(DISTINCT(questions.id)) AS num_questions, CAST(COUNT(question_likes.user_id) AS FLOAT) AS num_likes
    FROM
      users
    JOIN
      questions ON questions.author_id = users.id
    LEFT OUTER JOIN
      question_likes ON question_likes.question_id = questions.id
    WHERE
      users.id = ?
    SQL
    value = ans['num_likes'] / ans['num_questions']
  end

end
