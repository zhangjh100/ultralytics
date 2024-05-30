from ultralytics.data.converter import convert_coco

convert_coco(
    labels_dir="../datasets/cofw/annotations",
    save_dir="../datasets/cofw/",
    use_segments=False,
    use_keypoints=True,
    cls91to80=False,
    lvis=False,
)
