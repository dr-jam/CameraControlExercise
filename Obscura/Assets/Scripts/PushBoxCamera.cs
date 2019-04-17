using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Obscura
{
    public class PushBoxCamera : AbstractCameraController
    {
        [SerializeField] public Vector3 TopLeft;
        [SerializeField] public Vector3 BottomRight;
        private Camera ManagedCamera;
        private LineRenderer CameraLineRenderer;

        private void Awake()
        {
            this.ManagedCamera = this.gameObject.GetComponent<Camera>();
            this.CameraLineRenderer = this.gameObject.GetComponent<LineRenderer>();
        }

        //Use the LateUpdate message to avoid setting the camera's position before
        //GameObject locations are finalized.
        void LateUpdate()
        {
            var targetPosition = this.Target.transform.position;
            var cameraPosition = this.ManagedCamera.transform.position;
            if (targetPosition.y >= cameraPosition.y + TopLeft.y)
            {
                cameraPosition = new Vector3(cameraPosition.x, targetPosition.y - TopLeft.y, cameraPosition.z);
            }
            if (targetPosition.y <= cameraPosition.y + BottomRight.y)
            {
                cameraPosition = new Vector3(cameraPosition.x, targetPosition.y- BottomRight.y, cameraPosition.z);
            }
            if (targetPosition.x >= cameraPosition.x + BottomRight.x)
            {
                cameraPosition = new Vector3(targetPosition.x - BottomRight.x, cameraPosition.y, cameraPosition.z);
            }
            if (targetPosition.x <= cameraPosition.x + TopLeft.x)
            {
                cameraPosition = new Vector3(targetPosition.x- TopLeft.x, cameraPosition.y, cameraPosition.z);
            }

            this.ManagedCamera.transform.position = cameraPosition;

            if (this.DrawLogic)
            {
                this.CameraLineRenderer.enabled = true;
                this.DrawCameraLogic();
            }
            else
            {
                this.CameraLineRenderer.enabled = false;
            }
        }

        public override void DrawCameraLogic()
        {
            this.CameraLineRenderer.positionCount = 5;
            this.CameraLineRenderer.useWorldSpace = false;
            this.CameraLineRenderer.SetPosition(0, TopLeft);
            this.CameraLineRenderer.SetPosition(1, new Vector3(BottomRight.x, TopLeft.y, TopLeft.z));
            this.CameraLineRenderer.SetPosition(2, BottomRight);
            this.CameraLineRenderer.SetPosition(3, new Vector3(TopLeft.x, BottomRight.y, BottomRight.z));
            this.CameraLineRenderer.SetPosition(4, TopLeft);
        }
    }
}
