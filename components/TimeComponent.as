/**
 * Created by IntelliJ IDEA.
 * User: dartavion
 * Date: 11/23/11
 * Time: 1:32 PM
 * To change this template use File | Settings | File Templates.
 */
package components{
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.MouseEvent;

    import mx.collections.ArrayCollection;
    import mx.events.FlexEvent;

    import mx.events.FlexMouseEvent;

    import skins.TimeComponentSkin;

    import spark.components.Group;
    import spark.components.Image;
    import spark.components.List;
    import spark.components.PopUpAnchor;
    import spark.components.VGroup;
    import spark.components.supportClasses.SkinnableComponent;
    import spark.components.supportClasses.TextBase;
    import spark.events.DropDownEvent;
    import spark.events.IndexChangeEvent;
    import spark.events.ListEvent;

    [Event("open", type="spark.events.DropDownEvent")]
    [Event(name="change", type="mx.events.ListEvent")]

    [SkinState("open")]

    [SkinState("over")]

    public class TimeComponent extends SkinnableComponent {
        [SkinPart("false")]
        public var icon:Image;

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

        [SkinPart("false")]
        public var labelText:TextBase;

        // in case we want to expose later
        [Embed(source="../assets/time-icon.png")]
        [Bindable]
        public var iconImage:Class;

        [Bindable]
        public var _dataProvider:ArrayCollection;

        private var _isOpen:Boolean = false;
        private var _isOver:Boolean = false;

        private var _useIcon:Boolean;

        private var _selectedItem:String = "Please select an item";
        private var _selectedIndex:Number;
        private var buttonWidth:Number;

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
                if (!useIcon) {
                    labelText.visible = true;
                    labelText.includeInLayout = true;
                    buttonWidth = 100;
                }
            }
            if(instance == icon){
                if(useIcon) {
                    icon.source = iconImage;
                    icon.toolTip = selectedItem;
                    icon.visible = true;
                    icon.includeInLayout = true;
                    buttonWidth = 16;
                }
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

            _selectedItem = String(currentDataItem);
            _selectedIndex = Number(currentIndex);
            labelText.text = String(currentDataItem);
            icon.toolTip = String(currentDataItem);
            closeDropDown();
            this.dispatchEvent(new ListEvent(Event.CHANGE));
        }

        override protected function commitProperties():void {
            super.commitProperties();
            updateLabel();
            updateTheListDataProvider();
        }

        override protected function measure():void {
            super.measure();
        }

        private function updateTheListDataProvider():void {
            if(theList){
                theList.dataProvider = dataProvider;
            }
            if(_selectedIndex != -1){
                theList.selectedIndex = selectedIndex;
                labelText.text = String(theList.selectedItem);
                icon.toolTip = String(theList.selectedItem);
                trace(selectedIndex, _selectedIndex);
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
                var label:String = _selectedItem;
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

        public function get useIcon():Boolean {
            return _useIcon;
        }

        public function set useIcon(value:Boolean):void {
            _useIcon = value;
        }
    }
}
