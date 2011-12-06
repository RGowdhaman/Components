/**
 * Created by IntelliJ IDEA.
 * User: dartavion
 * Date: 11/23/11
 * Time: 1:32 PM
 * To change this template use File | Settings | File Templates.
 */
package components{
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.TextLineMetrics;

    import mx.collections.ArrayCollection;
    import mx.controls.Image;
    import mx.events.FlexMouseEvent;
    import mx.events.ListEvent;

    import skins.TimeComponentSkin;

    import spark.components.Group;
    import spark.components.Label;
    import spark.components.List;
    import spark.components.PopUpAnchor;
    import spark.components.VGroup;
    import spark.components.supportClasses.SkinnableComponent;
    import spark.events.DropDownEvent;
    import spark.events.IndexChangeEvent;

    [Event("open", type="spark.events.DropDownEvent")]
    [Event(name="change", type="mx.events.ListEvent")]

    [SkinState("open")]

    [SkinState("over")]

    public class TimeComponent extends SkinnableComponent {
        [SkinPart("true")]
        public var popup:PopUpAnchor;

        [SkinPart("true")]
        public var dropDown:Group;

        [SkinPart("true")]
        public var openButton:Group;

        [SkinPart("true")]
        public var activeGroup:VGroup;

        [SkinPart("true")]
        public var theList:List;

        [SkinPart("true")]
        public var labelText:Label;

        [Bindable]
        public var _dataProvider:ArrayCollection;

        private var _isOpen:Boolean = false;
        private var _isOver:Boolean = false;

        private var _selectedItem:String = "Please select an item";
        private var _selectedIndex:Number;
        private var buttonWidth:Number;
        private var _containerTitleWidth:Number;
        private var _containerWidth:Number;

        private var _containerTitle:Label;
        private var _containerHelpIcon:Image;

        public function TimeComponent() {
            super();
            init();
        }

        private function init():void {
            this.useHandCursor = true;
            this.buttonMode = true;
            setStyle("skinClass", TimeComponentSkin);
        }

        override public function set enabled(value:Boolean):void {
            if (value == enabled)
                return;

            super.enabled = value;
            if (openButton)
                openButton.enabled = value;
        }

        override protected function getCurrentSkinState():String {
            return !enabled ? "disabled" : _isOpen ? "open" : _isOver ? "over" : "normal";
        }

        override protected function partAdded(partName:String, instance:Object):void {
            super.partAdded(partName, instance);
            if (instance == openButton) {
                openButton = setupOpenButton(Group(openButton));
            }
            if (instance == theList) {
                theList = setupTheList(theList);
            }
            if(instance == dropDown){
                dropDown = this.setupDropDown(Group(dropDown));
            }
            if(instance == labelText){
                labelText.visible = true;
                labelText.includeInLayout = true;


                labelText.verticalCenter = 0;
                buttonWidth = 100;
            }
        }

        override protected function partRemoved(partName:String, instance:Object):void {
            super.partRemoved(partName, instance);
            if (instance == openButton) {
                Group(openButton).removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            }
            if (instance == theList) {
                theList.removeEventListener(IndexChangeEvent.CHANGE, onIndexClick);
            }
            if(instance == dropDown){
                Group(dropDown).removeEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE, mouseDownOutsideHandler);
            }
        }

        private function setupTheList(list:List):List {
            list.setStyle("contentBackgroundAlpha", 0);
            list.addEventListener(IndexChangeEvent.CHANGE, onIndexClick);

            return list;
        }

        protected function onIndexClick(event:IndexChangeEvent):void {
            var currentIndex:int = event.currentTarget.selectedIndex;
            var currentDataItem:Object = event.currentTarget.selectedItem;

            selectedItem = String(currentDataItem);
            selectedIndex = Number(currentIndex);
            labelText.text = String(currentDataItem);
            closeDropDown();
            this.dispatchEvent(new ListEvent(Event.CHANGE));
        }

        override protected function commitProperties():void {
            super.commitProperties();
            updateLabel();
            updateTheListDataProvider();
        }

        private function updateTheListDataProvider():void {
            if(theList){
                theList.dataProvider = dataProvider;
            }

            if(_selectedIndex != -1){
				theList.selectedIndex = -1;
                theList.selectedIndex = selectedIndex;
                labelText.text = String(theList.selectedItem);

                prepareComponentLabel();
            }
        }

        private function prepareComponentLabel():void {
            var thisComponentTitle:TextLineMetrics = labelText.measureText(labelText.text);
            var thisComponentTitleWidth:Number = Number(thisComponentTitle.width);
            var parentComponentWidth:Number = containerWidth;
            var containerTitleWidth:Number = 0;
            var helpIconWidth:Number;
            var padding:Number = (containerTitle.getStyle("paddingLeft") + containerTitle.getStyle("paddingLeft"));

            if(containerTitle){
                var lm:TextLineMetrics = containerTitle.measureText(containerTitle.text);
                containerTitleWidth = lm.width;
            }

            if(containerHelpIcon){
                helpIconWidth = containerHelpIcon.width;
            }




            if ((thisComponentTitleWidth + containerTitleWidth + padding) < parentComponentWidth) {
                labelText.width = thisComponentTitleWidth + padding + 5;
                trace(labelText.width);
                labelText.toolTip = String(theList.selectedItem);
                labelText.maxDisplayedLines = 1;

            } else {
                labelText.toolTip = "";
            }

        }

        public function openDropDown():void {
            _isOpen = true;
            invalidateSkinState();
            this.dispatchEvent(new DropDownEvent(DropDownEvent.OPEN));
        }

        public function closeDropDown():void {
            _isOpen = false;
            _isOver = false;
            invalidateSkinState();
            this.dispatchEvent(new DropDownEvent(DropDownEvent.CLOSE));
        }

        private function updateLabel():void {
            if(labelText){
                var label:String = selectedItem;
                theList.selectedIndex = selectedIndex;
                labelText.text = label;
            }
        }

        private function setupOpenButton(ob:Group):Group {
            (buttonWidth > 16) ? ob.percentWidth = buttonWidth : ob.width = buttonWidth;
            ob.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            return ob;
        }

        private function mouseDownOutsideHandler(event:FlexMouseEvent):void {
            closeDropDown();
        }

        protected function onMouseDown(event:MouseEvent):void {
            if (_isOpen) {
                closeDropDown();
            } else {
                openDropDown();
            }
        }

        private function setupDropDown(dropDown:Group):Group {
            dropDown.addEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE, mouseDownOutsideHandler);
            return dropDown;
        }

        // GETTERS SETTERS
        public function get dataProvider():ArrayCollection {
            return _dataProvider;
        }

        public function set dataProvider(value:ArrayCollection):void {
            _dataProvider = value;
        }

        public function get selectedItem():String {
            return _selectedItem;
        }

        public function set selectedItem(value:String):void {
            _selectedItem = value;
        }

        public function get selectedIndex():Number {
            return _selectedIndex;
        }

        public function set selectedIndex(value:Number):void {
            if (value != _selectedIndex){
                _selectedIndex = value;
                invalidateSkinState();
            }
        }

        public function get containerTitleWidth():Number {
            return _containerTitleWidth;
        }

        public function set containerTitleWidth(value:Number):void {
            _containerTitleWidth = value;
            validateNow();
        }

        public function get containerWidth():Number {
            return _containerWidth;
        }

        public function set containerWidth(value:Number):void {
            _containerWidth = value;
            validateNow();
        }

        public function get containerTitle():Label {
            return _containerTitle;
        }

        public function set containerTitle(value:Label):void {
            _containerTitle = value;
        }

        public function get containerHelpIcon():Image {
            return _containerHelpIcon;
        }

        public function set containerHelpIcon(value:Image):void {
            _containerHelpIcon = value;
        }
    }
}
