class Exercise::Representation < ApplicationRecord
  serialize :mapping, JSON
  has_markdown_field :feedback

  belongs_to :exercise
  belongs_to :source_submission, class_name: "Submission"
  belongs_to :feedback_author, optional: true, class_name: "User"
  belongs_to :feedback_editor, optional: true, class_name: "User"
  belongs_to :track, optional: true
  has_one :solution, through: :source_submission

  enum feedback_type: { essential: 0, actionable: 1, non_actionable: 2 }, _prefix: :feedback

  has_many :submission_representations,
    class_name: "Submission::Representation",
    foreign_key: :ast_digest,
    primary_key: :ast_digest,
    inverse_of: :exercise_representation
  has_many :submission_representation_submissions, through: :submission_representations, source: :submission

  scope :without_feedback, -> { where(feedback_type: nil) }
  scope :with_feedback, -> { where.not(feedback_type: nil) }
  scope :mentored_by, ->(mentor) { where(submission_representations: mentor.submission_representations) }
  scope :track_mentored_by, ->(mentor) { where(track_id: mentor.track_mentorships.select(:track_id)) }
  scope :edited_by, ->(mentor) { where(feedback_author: mentor).or(where(feedback_editor: mentor)) }
  scope :for_track, ->(track) { where(track:) }

  before_create do
    self.uuid = SecureRandom.compact_uuid
    self.track_id = exercise.track_id
  end

  def num_times_used
    submission_representations.count
  end

  def has_essential_feedback?
    has_feedback? && feedback_essential?
  end

  def has_actionable_feedback?
    has_feedback? && feedback_actionable?
  end

  def has_non_actionable_feedback?
    has_feedback? && feedback_non_actionable?
  end

  def has_feedback?
    [feedback_markdown, feedback_author_id, feedback_type].all?(&:present?)
  end

  def appears_frequently?
    num_submissions >= APPEARS_FREQUENTLY_MIN_NUM_SUBMISSIONS
  end

  APPEARS_FREQUENTLY_MIN_NUM_SUBMISSIONS = 5
  private_constant :APPEARS_FREQUENTLY_MIN_NUM_SUBMISSIONS
end
