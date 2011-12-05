package components {
	import flash.events.Event;

	import mx.collections.ArrayCollection;

    import skins.TitledContainerSkin;

    import spark.components.SkinnableContainer;

	public class TitledContainer extends SkinnableContainer {
		[Bindable]
		public var title:String;

		[Bindable]
		public var querySetList:ArrayCollection = new ArrayCollection();


		private var querySetSelectionCallback:Function;

		public function TitledContainer() {
			setStyle("skinClass", Class(TitledContainerSkin));
		}


		public function selectionChangedHandler(event:Event):void {
			//querySetSelectionCallback.call(NaN, (skin as TitledContainerSkin).timePicker.selectedItem);
		}

        [SkinPart("false")]
        public var timePicker:TimeComponent;

		public function setListData(querySetNames:ArrayCollection, defaultName:String, selectionCallback:Function):void {
			querySetList.removeAll();
			querySetList.addAll(querySetNames);
			querySetSelectionCallback = selectionCallback;
			timePicker.selectedItem = defaultName;
			timePicker.selectedIndex = querySetNames.getItemIndex(defaultName);

		}
	}
}
