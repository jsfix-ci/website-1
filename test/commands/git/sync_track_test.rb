require "test_helper"

class Git::SyncTrackTest < ActiveSupport::TestCase
  test "no change when git sync SHA matches HEAD SHA" do
    track = create :track, slug: 'fsharp', synced_to_git_sha: "HEAD"

    Git::SyncConcept.expects(:call).never
    Git::SyncConceptExercise.expects(:call).never
    # Git::SyncPracticeExercise.expects(:call).never # TOOD
    Git::SyncTrack.(track)

    refute track.changed?
  end

  test "resyncs when force_sync is passed" do
    track = create :track, slug: 'fsharp', synced_to_git_sha: "HEAD"

    Git::SyncConcept.expects(:call).at_least_once
    Git::SyncConceptExercise.expects(:call).at_least_once
    # Git::SyncPracticeExercise.expects(:call).at_least_once # TOOD

    Git::SyncTrack.(track, force_sync: true)

    refute track.changed?
  end

  test "git sync SHA changes to HEAD SHA when there are no changes" do
    track = create :track, slug: 'fsharp', synced_to_git_sha: "72c4dc096d3f7a5c01c4545d3d6570b5aa3e4252"

    Git::SyncTrack.(track)

    git_track = Git::Track.new(track.slug, repo_url: track.repo_url)
    assert_equal git_track.head_sha, track.synced_to_git_sha
  end

  test "git sync SHA changes to HEAD SHA when there are changes" do
    track = create :track, slug: 'fsharp', active: true, synced_to_git_sha: "98403713252d41babae8353793ea5ec9ad7d770f"

    Git::SyncTrack.(track)

    git_track = Git::Track.new(track.slug, repo_url: track.repo_url)
    assert_equal git_track.head_sha, track.synced_to_git_sha
  end

  test "git sync SHA does not change when concept syncing fails" do
    track = create :track, slug: 'fsharp', active: true, synced_to_git_sha: "98403713252d41babae8353793ea5ec9ad7d770f"
    Git::SyncConcept.expects(:call).raises(RuntimeError)

    assert_raises RuntimeError do
      Git::SyncTrack.(track)
    end

    assert_equal "98403713252d41babae8353793ea5ec9ad7d770f", track.synced_to_git_sha
  end

  test "git sync SHA does not change when concept exercise syncing fails" do
    track = create :track, slug: 'fsharp', active: true, synced_to_git_sha: "98403713252d41babae8353793ea5ec9ad7d770f"
    Git::SyncConceptExercise.expects(:call).raises(RuntimeError)

    assert_raises RuntimeError do
      Git::SyncTrack.(track)
    end

    assert_equal "98403713252d41babae8353793ea5ec9ad7d770f", track.synced_to_git_sha
  end

  test "git sync SHA does not change when practice exercise syncing fails" do
    skip # TODO: re-enable once we import practice exercises

    track = create :track, slug: 'fsharp', active: true, synced_to_git_sha: "98403713252d41babae8353793ea5ec9ad7d770f"
    Git::SyncPracticeExercise.expects(:call).raises(RuntimeError)

    assert_raises RuntimeError do
      Git::SyncTrack.(track)
    end

    assert_equal "98403713252d41babae8353793ea5ec9ad7d770f", track.synced_to_git_sha
  end

  test "track is updated when there are changes" do
    track = create :track, slug: "fsharp",
                           title: "F#",
                           active: true,
                           blurb: "F# is a strongly-typed, functional language that is part of Microsoft's .NET language stack. Although F# is great for data science problems, it can elegantly handle almost every problem you throw at it.", # rubocop:disable Layout/LineLength
                           synced_to_git_sha: "98403713252d41babae8353793ea5ec9ad7d770f"

    Git::SyncTrack.(track)

    assert_equal "F# is a strongly-typed, functional language.", track.blurb # rubocop:disable Layout/LineLength
  end

  test "track is updated when tags change" do
    track = create :track, slug: "fsharp",
                           title: "F#",
                           active: true,
                           blurb: "F# is a strongly-typed, functional language that is part of Microsoft's .NET language stack. Although F# is great for data science problems, it can elegantly handle almost every problem you throw at it.", # rubocop:disable Layout/LineLength
                           tags: ["compiles to:Bytecode", "runtime/common_language_runtime"],
                           synced_to_git_sha: "3b0e5ae6a166dd42af27217d1868a74d42023b8b"

    Git::SyncTrack.(track)

    expected = [
      "compiles_to/bytecode",
      "runtime/common_language_runtime",
      "paradigm/functional",
      "paradigm/object_oriented",
      "typing/static"
    ]
    assert_equal expected, track.tags
  end

  test "adds new concepts defined in config.json" do
    track = create :track, slug: 'fsharp', synced_to_git_sha: 'ab0b9be3162f6ec4ed6d7c46b55a8bf2bd117ffb'

    Git::SyncTrack.(track)

    assert track.concepts.where(uuid: 'd0fe01c7-d94b-4d6b-92a7-a0055c5704a3').exists?
  end

  test "concept exercises use track concepts for taught concepts" do
    csharp_track = create :track, slug: 'charp'
    csharp_concept = create :track_concept, track: csharp_track, slug: 'basics'
    fsharp_track = create :track, slug: 'fsharp', synced_to_git_sha: 'ab0b9be3162f6ec4ed6d7c46b55a8bf2bd117ffb'
    fsharp_concept = create :track_concept, track: fsharp_track, slug: 'basics', uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215'

    Git::SyncTrack.(fsharp_track)

    fsharp_concept_exercise = fsharp_track.concept_exercises.find_by(uuid: '1fc8216e-6519-11ea-bc55-0242ac130003')
    assert_includes fsharp_concept_exercise.taught_concepts, fsharp_concept
    refute_includes fsharp_concept_exercise.taught_concepts, csharp_concept
  end

  test "concept exercises use track concepts for prerequisites" do
    csharp_track = create :track, slug: 'charp'
    csharp_concept = create :track_concept, track: csharp_track, slug: 'basics'
    fsharp_track = create :track, slug: 'fsharp', synced_to_git_sha: 'ab0b9be3162f6ec4ed6d7c46b55a8bf2bd117ffb'
    fsharp_concept = create :track_concept, track: fsharp_track, slug: 'basics', uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215'

    Git::SyncTrack.(fsharp_track)

    fsharp_concept_exercise = fsharp_track.concept_exercises.find_by(uuid: '9c2aad8a-53ee-11ea-8d77-2e728ce88125')
    assert_includes fsharp_concept_exercise.prerequisites, fsharp_concept
    refute_includes fsharp_concept_exercise.prerequisites, csharp_concept
  end

  test "adds new concept exercises defined in config.json" do
    track = create :track, slug: 'fsharp', synced_to_git_sha: 'ab0b9be3162f6ec4ed6d7c46b55a8bf2bd117ffb'

    Git::SyncTrack.(track)

    assert track.concept_exercises.where(uuid: '6ea2765e-5885-11ea-82b4-0242ac130003').exists?
  end

  test "adds new practice exercises defined in config.json" do
    skip # TODO: re-enable once we import practice exercises

    track = create :track, slug: 'fsharp', synced_to_git_sha: 'ab0b9be3162f6ec4ed6d7c46b55a8bf2bd117ffb'

    Git::SyncTrack.(track)

    assert track.practice_exercises.where(uuid: '2ee3cc7a-db3f-4668-9983-ed6d0fea95d1').exists?
  end

  test "syncs all concepts" do
    track = create :track, slug: 'fsharp', synced_to_git_sha: 'ab0b9be3162f6ec4ed6d7c46b55a8bf2bd117ffb'

    Git::SyncTrack.(track)

    assert_equal 5, track.concepts.length
    track.concepts.each do |concept|
      assert_equal track.git.head_sha, concept.synced_to_git_sha
    end
  end

  test "syncs all concept exercises" do
    track = create :track, slug: 'fsharp', synced_to_git_sha: 'ab0b9be3162f6ec4ed6d7c46b55a8bf2bd117ffb'

    Git::SyncTrack.(track)

    assert_equal 4, track.concept_exercises.length
    track.concept_exercises.each do |concept_exercise|
      assert_equal track.git.head_sha, concept_exercise.synced_to_git_sha
    end
  end

  test "syncs all practice exercises" do
    skip # TODO: re-enable once we import practice exercises

    track = create :track, slug: 'fsharp', synced_to_git_sha: 'ab0b9be3162f6ec4ed6d7c46b55a8bf2bd117ffb'

    Git::SyncTrack.(track)

    assert_equal 3, track.practice_exercises.length
    track.practice_exercises.each do |practice_exercise|
      assert_equal track.git.head_sha, practice_exercise.synced_to_git_sha
    end
  end

  test "update is only called once" do
    # Use the first commit in the repo
    track = create :track, slug: 'fsharp', synced_to_git_sha: '041e4efbdbc09c4c7f913e2f1259c4f1970d88ca'

    Git::Repository.any_instance.stubs(keep_up_to_date?: false)
    Git::Repository.any_instance.expects(:fetch!).once
    Git::SyncTrack.(track)
  end
end
